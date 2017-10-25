"""
  To restart PNDA services
"""
import re
import time
import logging
from cm_api.api_client import ApiResource
from cm_api.endpoints import hosts


logging.basicConfig(level=logging.DEBUG)
LOGGER = logging.getLogger(__name__)

# retry the start service only for every DOWN_COUNT_MAX
DOWN_COUNT_MAX = 10
# maximum retry count is RETRY_COUNT_MAX
RETRY_COUNT_MAX = 3
# retry_count will reset after RETRY_COUNT_MAX
RETRY_COUNT_RESET = 10

CMS_SERVICE_LIST = [
    'SERVICEMONITOR',
    'ALERTPUBLISHER',
    'EVENTSERVER',
    'HOSTMONITOR']

def managehadoopclusterrestart():
    """
      This procedure gets services from grains
    """
    hadoop_distro = "CDH" # Get hadoop managment service from pillar or grains
    try:
        servicelist = __salt__['grains.get']('serviceList')  # pylint: disable=E0602,E0603
        if not servicelist:
            servicelist = {}
    except BaseException:
        servicelist = {}
    dependencylist = {
        "SERVICEMONITOR": [],
        "HOSTMONITOR": [],
        "ALERTPUBLISHER": ['SERVICEMONITOR'],
        "EVENTSERVER": ['SERVICEMONITOR'],
        "ZOOKEEPER": ['SERVICEMONITOR'],
        "HDFS": ['ZOOKEEPER'],
        "HBASE": ["ZOOKEEPER", "HDFS"],
        "YARN": ["ZOOKEEPER", "HDFS"],
        "HIVE": ["ZOOKEEPER", "YARN"],
        "SPARK_ON_YARN": ["YARN"],
        "IMPALA": ["HBASE", "HDFS", "HIVE"],
        "OOZIE": ["ZOOKEEPER", "YARN"],
        "HUE": ["ZOOKEEPER", "HBASE", "HIVE", "IMPALA", "OOZIE"]
    }

    connection_object = check_connectivity()
    if not connection_object:
        LOGGER.error("CDH Connection issue")
        return False

        # check the CMS and hadoop status and created in Grains(serviceList)
    servicelist = getservicestatus(
        connection_object,
        hadoop_distro=hadoop_distro,
        servicelist=servicelist)

    # check the CMS and hadoop status and start the service node based
    result = checkstatusandtrigger(
        connection_object,
        hadoop_distro=hadoop_distro,
        servicelist=servicelist,
        dependencylist=dependencylist)

    return result


def check_connectivity():
    """
      Procedure to check connection cloudera manager
    """
    hadoop_distro = __salt__['pillar.get']('hadoop.distro')  # pylint: disable=E0602,E0603
    if hadoop_distro == 'CDH':
        cm_host = __salt__['pnda.hadoop_manager_ip']()  # pylint: disable=E0602,E0603
        cm_user = __salt__['pillar.get']('admin_login:user')  # pylint: disable=E0602,E0603
        cm_pass = __salt__['pillar.get']('admin_login:password')  # pylint: disable=E0602,E0603
        try:
            cm_api = ApiResource(
                cm_host,
                version=11,
                username=cm_user,
                password=cm_pass)
            if not cm_api:
                return False
            return cm_api
        except BaseException:
            return False
    else:
        LOGGER.error("HDP not implemented")
        return False


def getservicestatus(connection_object, hadoop_distro, servicelist):
    """
      Procedure to check status of the services
    """
    if hadoop_distro == 'CDH':
        # get cluster name
        for cluster_detail in connection_object.get_all_clusters():
            cluster_name = cluster_detail.name
            break
        cluster_manager = connection_object.get_cluster(cluster_name)

        # Cloudra management services
        cloudera_manager = connection_object.get_cloudera_manager()
        cms_service = cloudera_manager.get_service()
        for role in cms_service.get_all_roles():
            role_name = str(role.type)
            if role_name not in servicelist.keys():
                servicelist[role_name] = {}
            name = hosts.get_host(role._resource_root, role.hostRef.hostId)
            hostname = str(name.hostname)
            if role_name not in servicelist[role_name].keys():
                servicelist[role_name][role_name] = {hostname: {}}
            elif hostname not in servicelist[role_name][role_name].keys():
                servicelist[role_name][role_name][hostname] = {}
            status = "Maintenance" if role.maintenanceMode else str(
                role.entityStatus)
            servicelist[role_name][role_name][hostname]["status"] = status
            servicelist[role_name]['status'] = str(status)

            # Hadoop Services
        for service in cluster_manager.get_all_services():
            service_name = str(service.type)
            if service_name not in servicelist.keys():
                servicelist[service_name] = {}
            for role in service.get_all_roles():
                role_name = str(role.type)
                name = hosts.get_host(role._resource_root, role.hostRef.hostId)
                hostname = str(name.hostname)
                if role_name not in servicelist[service_name].keys():
                    servicelist[service_name][role_name] = {hostname: {}}
                elif hostname not in servicelist[service_name][role_name].keys():
                    servicelist[service_name][role_name][hostname] = {}
                status = "Maintenance" if role.maintenanceMode else str(
                    role.entityStatus)
                servicelist[service_name][role_name][hostname]["status"] = status
            servicelist[service_name]['status'] = str(service.entityStatus)
    # Grain update not working properly , so reset value and added new value
    __salt__['grains.set']("serviceList", {}, True)  # pylint: disable=E0602,E0603
    __salt__['grains.set'](  # pylint: disable=E0602,E0603
        "serviceList", servicelist, True)
    return servicelist


def checkdependency(service_name, servicelist, dependencylist):
    """
      Procedure to check dependency service are in GOOD_HEALTH
    """
    for sname in dependencylist[service_name]:
        status = servicelist[sname]['status']
        if not re.search("GOOD_HEALTH|NONE", str(status)):
            return False

    return True


def checkstatusandtrigger(
        connection_object,
        hadoop_distro,
        servicelist,
        dependencylist):
    """
      Procedure to check service status and start if is not GOOD_HEALTH
    """
    result = True
    for service_name in servicelist.keys():
        for role_name in servicelist[service_name]:
            if role_name == "status":
                continue
            for node_name in servicelist[service_name][role_name]:
                status = servicelist[service_name][role_name][node_name]['status']
                counters = {}
                try:
                    counters['up_count'] = servicelist[service_name][role_name][node_name]['up_count']
                    counters['down_count'] = servicelist[service_name][role_name][node_name]['down_count']
                    counters['retry_count'] = servicelist[service_name][role_name][node_name]['retry_count']
                except BaseException:
                    counters['up_count'] = 0
                    counters['down_count'] = 0
                    counters['retry_count'] = 0

                if re.search("Maintenance", str(status)):
                    LOGGER.debug("Maintenance mode")
                elif not re.search("GOOD_HEALTH|NONE", str(status)):
                    LOGGER.debug(
                        "{0} {1} {2} {3} ".format(
                            service_name,
                            role_name,
                            node_name,
                            status))
                    LOGGER.debug("{0}  ".format(counters))
                    counters['up_count'] = 0
                    dep = checkdependency(
                        service_name=service_name,
                        servicelist=servicelist,
                        dependencylist=dependencylist)
                    if dep and counters['retry_count'] < RETRY_COUNT_MAX and counters['down_count'] > DOWN_COUNT_MAX:
                        counters['retry_count'] += 1
                        counters['down_count'] = 0
                        if not startservice(
                                connection_object,
                                service_name=service_name,
                                role_name=role_name,
                                node_name=node_name):
                            result = False
                    else:
                        counters['down_count'] += 1
                else:
                    counters['up_count'] += 1
                    if counters['up_count'] > RETRY_COUNT_RESET:
                        counters['retry_count'] = 0
                # update Counters
                servicelist[service_name][role_name][node_name].update(
                    counters)
    # Grain update not working properly , so reset value and added new value
    __salt__['grains.set']("serviceList", {}, True)  # pylint: disable=E0602,E0603
    __salt__['grains.set'](  # pylint: disable=E0602,E0603
        "serviceList".format(service_name),  # pylint: disable=E1305
        servicelist, True)
    return result


def startservice(connection_object, service_name, role_name, node_name):
    """
      Procedure to start service
    """
    if service_name in CMS_SERVICE_LIST:
        cloudera_manager = connection_object.get_cloudera_manager()
        cms_service = cloudera_manager.get_service()
        for role in cms_service.get_all_roles():
            if str(role.type) == service_name:
                status, message = wait_on_command(
                    cms_service.start_roles(role.name))
                break
    else:
        for cluster_detail in connection_object.get_all_clusters():
            cluster_name = cluster_detail.name
            break
        cluster_manager = connection_object.get_cluster(cluster_name)
        status, message = wait_on_command([cluster_manager.start()])
        for service in cluster_manager.get_all_services():
            if service_name != service.type:
                continue
            for role in service.get_all_roles():
                if role_name != role.type:
                    continue
                name = hosts.get_host(role._resource_root, role.hostRef.hostId)
                hostname = str(name.hostname)
                if node_name != hostname:
                    continue
                status, message = wait_on_command(
                    service.start_roles(role.name))
                break
    if not status:
        LOGGER.error(
            "{0} service start failed, error message : {1}".format(
                service_name, message))
    return status


def wait_on_command(cmds):
    """
      Procedure to wait until command execution completes
    """
    messages = []
    success = False
    for cmd in cmds:
        logging.debug('Executing %s', cmd.name)
        while cmd.active is True and cmd.success is None:
            time.sleep(5)
            cmd = cmd.fetch()
        if cmd.active is None:
            messages.append('%s (cmd.active is None)' % cmd.resultMessage)
        if cmd.success is False:
            LOGGER.error('%s (cmd.success is False)' % cmd.resultMessage)
            messages.append('%s (cmd.success is False)' % cmd.resultMessage)
        elif cmd.success is None:
            LOGGER.error('%s (cmd.success is None)' % cmd.resultMessage)
            messages.append('%s (cmd.success is None)' % cmd.resultMessage)
        elif cmd.success is True:
            success = True
    return success, messages
