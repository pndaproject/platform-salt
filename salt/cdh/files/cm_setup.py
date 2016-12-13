"""
Name:       cm_setup
Purpose:    Drives the Cloudera Manager API to create a cluster and configure
            the various component services such as HDFS, HBase etc

Author:     PNDA team

Created:    14/03/2016
"""
import time
import urllib2
import string
import logging
import sys

import spur
from cm_api.endpoints.services import ApiServiceSetupInfo
from cm_api.api_client import ApiResource
from cm_api.endpoints import users

# Import Flavor configuration file
import cfg_flavor as _CFG

DEFAULT_PARCEL_REPO = 'http://archive.cloudera.com/cdh5/parcels/5.9.0/'
DEFAULT_PARCEL_VERSION = '5.9.0-1.cdh5.9.0.p0.23'

DEFAULT_LOG_FILE = '/tmp/cm_setup.log'

logging.basicConfig(filename=DEFAULT_LOG_FILE,
                    level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')


def pause_until_api_up(api):
    '''
    Wait for ten minutes for CM API to come up
    '''

    for _ in xrange(120):
        try:
            logging.info("Checking API availability....")
            api.get_all_hosts()
            return
        except Exception:
            logging.warning("API is not up")
            time.sleep(5)
    logging.error("The API did not come UP")
    sys.exit(-1)

def connect(cm_api, cm_username, cm_password, use_proxy=False):
    '''
    Wait for ten minutes for CM to come up
    '''

    for _ in xrange(120):
        try:
            logging.info("Checking CM availability....")
            # change name of proxy if necessary
            proxy = urllib2.ProxyHandler({'http': 'proxy'})

            api = ApiResource(cm_api, username=cm_username, password=cm_password)

            if use_proxy:
            # pylint: disable=W0212
                api._client._opener.add_handler(proxy)

            cloudera_manager = api.get_cloudera_manager()
            api.get_user(cm_username)

            return api, cloudera_manager
        except Exception:
            logging.warning("CM is not up")
            time.sleep(5)
    logging.error("CM did not come UP")
    sys.exit(-1)

def create_hosts(api, cloudera_manager, user, nodes, key_name):

    key = file(key_name, 'rb')
    key_string = key.read()
    new_nodes = []
    hosts_toinstall = []
    hosts_current = [h.ipAddress for h in api.get_all_hosts()]
    for host in nodes:
        if host['private_addr'] not in hosts_current:
            hosts_toinstall.append(host['private_addr'])
            new_nodes.append(host)

    logging.info(hosts_toinstall)

    if len(hosts_toinstall) > 0:

        for attempt in xrange(1, 4):
            logging.info('Host install attempt %d', attempt)
            success, msgs = wait_on_command(cloudera_manager.host_install(user,
                                                                          hosts_toinstall,
                                                                          private_key=key_string,
                                                                          java_install_strategy="NONE",
                                                                          parallel_install_count=4))
            if success:
                break
            else:
                logging.warn('create_hosts: ' + ' '.join(msgs))
                if attempt == 3:
                    logging.error('Giving up on create_hosts: ' + ' '.join(msgs))
                    sys.exit(-1)

    return new_nodes

def wait_on_success(cmd):
    success, msgs = wait_on_command(cmd)
    if not success:
        logging.error('%s: ' + ' '.join(msgs), cmd.name)
        sys.exit(-1)

def wait_on_command(cmd):
    messages = []
    success = False

    logging.info('Executing %s', cmd.name)

    while cmd.active is True and cmd.success is None:
        time.sleep(5)
        cmd = cmd.fetch()

    if cmd.active is None:
        messages.append('%s (cmd.active is None)' % cmd.resultMessage)
    if cmd.success is False:
        messages.append('%s (cmd.success is False)' % cmd.resultMessage)
    elif cmd.success is None:
        messages.append('%s (cmd.success is None)' % cmd.resultMessage)
    elif cmd.success is True:
        success = True

    return success, messages


def assign_host_ids(api, nodes):
    i = 0
    for host_c in api.get_all_hosts():
        for host in nodes:
            if host_c.ipAddress == host['private_addr']:
                host['id'] = host_c.hostId
                host['idx'] = i
                i += 1
                logging.info("Assigned %s to %s", host_c.hostId, host['private_addr'])


def create_cluster(api, cluster_name):
    cluster = None

    try:
        hosts = api.get_all_hosts()
        cluster = api.create_cluster(cluster_name, "CDH5")
        cluster.add_hosts([host.hostId for host in hosts])
    except Exception:
        logging.error("Error while creating cluster", exc_info=True)
        raise

    return cluster


def process_parcel_state(cluster, product, parcel_version, check_complete):

    error_count = 0
    while True:
        parcel = cluster.get_parcel(product, parcel_version)
        if check_complete(parcel):
            break
        logging.info("progress: %s / %s", parcel.state.progress, parcel.state.totalProgress)

        if parcel.state.errors:
            logging.info("Parcel Error: %s", str(parcel.state.errors))
            logging.info("Retrying...")
            error_count += 1
            if error_count > 30:
                raise Exception(str(parcel.state.errors))
            else:
                time.sleep(60)

        time.sleep(30)


def check_parcel_download_state(parcel):

    if parcel.stage == 'DOWNLOADED' or parcel.stage == 'DISTRIBUTED' or parcel.stage == 'ACTIVATED':
        return True
    return False


def check_parcel_distribution_state(parcel):

    if parcel.stage == 'DISTRIBUTED' or parcel.stage == 'ACTIVATED':
        return True
    return False


def install_parcel(cloudera_manager, cluster, product, parcel_repo, parcel_version):

    if parcel_repo is None:
        parcel_repo = DEFAULT_PARCEL_REPO
    if parcel_version is None:
        parcel_version = DEFAULT_PARCEL_VERSION

    # this is handled slightly differently to other config updates as we don't
    # want to lose any existing configuration
    cm_config = cloudera_manager.get_config(view='full')
    repo_config = cm_config['REMOTE_PARCEL_REPO_URLS']
    repo_config_value = repo_config.value or repo_config.default
    cloudera_manager.update_config({'REMOTE_PARCEL_REPO_URLS': "%s,%s" % (repo_config_value, parcel_repo),
                                    'PARCEL_DISTRIBUTE_RATE_LIMIT_KBS_PER_SECOND': '1048576'})

    # update_config doesn't return a command object we can wait on, however the
    # parcel is not available to download until the change has propagated, which takes
    # a few seconds

    time.sleep(5)

    for _ in xrange(120):
        try:
            parcel = cluster.get_parcel(product, parcel_version)
            break
        except Exception:
            logging.info("failed to get_parcel %s", parcel_version)
            time.sleep(5)

    logging.info("Got %s Parcel %s : Current State %s", product, parcel_version, parcel.stage)

    if parcel.stage != 'DOWNLOADED':
        parcel.start_download()
        process_parcel_state(cluster, product, parcel_version, check_parcel_download_state)
        logging.info("Downloaded parcel %s", parcel_version)


    parcel = cluster.get_parcel(product, parcel_version)
    logging.info("%s Parcel %s : Current State %s", product, parcel_version, parcel.stage)


    if parcel.stage != 'DISTRIBUTED':
        parcel.start_distribution()
        process_parcel_state(
            cluster,
            product,
            parcel_version,
            check_parcel_distribution_state)
        logging.info("Distributed CDH parcel %s", parcel_version)


    parcel = cluster.get_parcel(product, parcel_version)
    logging.info("%s Parcel %s : Current State %s", product, parcel_version, parcel.stage)

    if parcel.stage != 'ACTIVATED':
        parcel.activate()

    # use product name (e.g. 'CDH', or 'Anaconda')
    parcel = cluster.get_parcel(product, parcel_version)
    logging.info("%s Parcel %s : Current State %s", product, parcel_version, parcel.stage)


def create_cms(cloudera_manager, nodes):
    cms = None

    try:
        cms = cloudera_manager.create_mgmt_service(ApiServiceSetupInfo())
        cloudera_manager.auto_configure()
        assign_roles(cms, _CFG.CMS_CFG['roles'], nodes)
        apply_role_config(cms, _CFG.CMS_CFG['role_cfg'])
    except Exception:
        logging.error("Error while creating CMS", exc_info=True)
        raise

    return cms


def generic_expand_service(cluster, cfg, nodes):

    service = cluster.get_service(cfg['name'])

    assign_roles(service, cfg['roles'], nodes)

    return service

def generic_configure_service(cluster, cfg):

    service = cluster.get_service(cfg['name'])

    apply_role_config(service, cfg['role_cfg'])

    service.update_config(cfg['config'])

    return service

def generic_create_service(cluster, cfg, nodes):

    service = cluster.create_service(cfg['name'], cfg['service'])

    assign_roles(service, cfg['roles'], nodes)

    apply_role_config(service, cfg['role_cfg'])

    service.update_config(cfg['config'])

    return service


def create_mysql_connector_symlink(user, key, ip_addr, target_dir):
    # fire and forget
    try:
        config = {
            'host': ip_addr,
            'ssh_username': user,
            'ssh_pem_file': key,
            'ssh_commands': [
                [
                    "bash",
                    "-c",
                    ("TARGET_DIR=%s;"
                     "MYSQL_JAVA_CONNECTOR=/usr/share/java/mysql-connector-java.jar;"
                     "[ -f $MYSQL_JAVA_CONNECTOR ]&& sudo ln -s $MYSQL_JAVA_CONNECTOR $TARGET_DIR/mysql-connector-java.jar"
                     " || echo \"ERROR - Unable to create symbolic link for 'mysql-connector-java.jar'. Oozie service might not work properly.\"") %
                    (target_dir)]]}
        setup_remotehost(config)
    except Exception:
        logging.error("Error while creating mysql symlink", exc_info=True)
        raise

def create_hdfs_dirs(yarn):
    wait_on_success(yarn.create_yarn_job_history_dir())
    wait_on_success(yarn.create_yarn_node_manager_remote_app_log_dir())

def create_hive_tmp(user, key, ip_addr):
    # fire and forget
    try:
        config = {
            'host': ip_addr,
            'ssh_username': user,
            'ssh_pem_file': key,
            'ssh_commands': [
                ["bash", "-c", "sudo mkdir -p /data0/tmp"],
                ["bash", "-c", "sudo chmod 777 /data0/tmp"]
            ]
        }
        setup_remotehost(config)
    except Exception:
        logging.error("Error while creating hive temporary directory", exc_info=True)
        raise

def assign_roles(service, roles, nodes):

    for role in roles:
        r_list = []
        for node in nodes:
            if node['type'] == role['target']:
                idstr = node['id']
                idstr = idstr.replace("-", "")
                new_r = service.create_role(
                    "%s%s" %
                    (role['name'], idstr), role['type'], node['id'])
                r_list.append(new_r)
    return r_list


def get_role_vm(nodes, service, role_name):
    role_vm = {}
    service_details = service.get_role(role_name)
    host_id = service_details.hostRef.hostId
    for node in nodes:
        if node['id'] == host_id:
            role_vm = node
            break
    if role_vm:
        logging.info("identified %s", role_name)
    else:
        logging.error("FAILED TO IDENTIFY %s", role_name)
    return role_vm


def get_role_name(service, role_type):
    role_name = None
    for role in service.get_all_roles():
        if role.type == role_type:
            role_name = role.name
            break
    if role_name:
        logging.info("identified %s:%s", role_type, role_name)
    else:
        logging.error("FAILED TO IDENTIFY %s", role_type)
    return role_name


def apply_role_config(service, role_cfg):

    groups = service.get_all_role_config_groups()
    for rcg in groups:
        for role_cfg_item in role_cfg:
            if rcg.roleType == role_cfg_item['type']:
                rcg.update_config(role_cfg_item['config'])


def expand_services(cluster, nodes):
    try:
        logging.info("Expanding HDFS")
        hdfs = generic_expand_service(cluster, _CFG.HDFS_CFG, nodes)

        logging.info("Expanding HBase")
        hbase = generic_expand_service(cluster, _CFG.HBASE_CFG, nodes)

        logging.info("Expanding YARN")
        mapred = generic_expand_service(cluster, _CFG.MAPRED_CFG, nodes)

        logging.info("Expanding Impala")
        impala = generic_expand_service(cluster, _CFG.IMPALA_CFG, nodes)

        time.sleep(10)
        logging.info("Deploying client config")
        wait_on_success(cluster.deploy_client_config())

        logging.info("Starting new HDFS roles")
        start_roles(hdfs)

        logging.info("Starting new HBase roles")
        start_roles(hbase)

        logging.info("Starting new YARN roles")
        start_roles(mapred)

        logging.info("Starting new Impala roles")
        start_roles(impala)

    except Exception:
        logging.error("Error while expanding services", exc_info=True)
        raise

def insert_hue_dependencies(nodes, hue_config, hdfs, hbase):
    httpfs_role = get_role_name(hdfs, "HTTPFS")
    hbase_addr = get_role_vm(nodes, hbase, get_role_name(hbase, "HBASETHRIFTSERVER"))['private_addr']
    hbase_thrift_name = get_role_name(hbase, 'HBASETHRIFTSERVER')
    hue_config['hue_webhdfs'] = httpfs_role
    hue_config['hue_service_safety_valve'] = '[hbase]\r\n hbase_clusters=(HBase|%s:9090)' % (hbase_addr)
    hue_config['hue_hbase_thrift'] = hbase_thrift_name

def configure_services(cloudera_manager, cluster, nodes):
    try:
        logging.info("Applying config to CMS")
        cms = cloudera_manager.get_service()
        apply_role_config(cms, _CFG.CMS_CFG['role_cfg'])

        logging.info("Applying config to HDFS")
        insert_hdfs_replication_factor(nodes)
        hdfs = generic_configure_service(cluster, _CFG.HDFS_CFG)

        logging.info("Applying config to Zookeeper")
        generic_configure_service(cluster, _CFG.ZK_CFG)

        logging.info("Applying config to HBase")
        hbase = generic_configure_service(cluster, _CFG.HBASE_CFG)

        logging.info("Applying config to YARN")
        mapred = generic_configure_service(cluster, _CFG.MAPRED_CFG)

        logging.info("Applying config to Hive")
        generic_configure_service(cluster, _CFG.HIVE_CFG)

        logging.info("Applying config to Oozie")
        generic_configure_service(cluster, _CFG.OOZIE_CFG)

        logging.info("Applying config to Hue")
        insert_hue_dependencies(nodes, _CFG.HUE_CFG['config'], hdfs, hbase)
        generic_configure_service(cluster, _CFG.HUE_CFG)

        logging.info("Applying config to Spark")
        generic_configure_service(cluster, _CFG.SPARK_CFG)

        logging.info("Applying config to Impala")
        generic_configure_service(cluster, _CFG.IMPALA_CFG)

        time.sleep(10)

        logging.info("Restarting cluster")
        wait_on_success(cluster.restart(redeploy_client_configuration=True))

        logging.info("Restarting CMS")
        wait_on_success(cms.restart())

    except Exception:
        logging.error("Error while reconfiguring services", exc_info=True)
        raise

def start_roles(service):
    wait_on_success(service.restart())

def enable_hdfs_ha(nodes, hdfs, zk_name, name_service='HDFS-HA'):
    """
    Enable HDFS High availability using Quroum Journal Nodes and
    Automatic failover
    """
    logging.info("Setup HDFS HA and Redundancy")
    nn_name = get_role_name(hdfs, "NAMENODE")
    second_nn_node = get_role_vm(nodes, hdfs, get_role_name(hdfs, "SECONDARYNAMENODE"))
    if nn_name  and second_nn_node:
        wait_on_success(hdfs.enable_nn_ha(nn_name, second_nn_node['id'], name_service, [], None, None, None, None, None, zk_name))

def insert_hdfs_replication_factor(nodes):
    hdfs_repl_factor = min(3, sum(1 for n in nodes if n["type"] == "DATANODE"))
    logging.info("Replication factor for HDFS is %s", hdfs_repl_factor)
    _CFG.HDFS_CFG["config"]["dfs_replication"] = hdfs_repl_factor

def create_services(user, key, cluster, nodes, ha_enabled):

    try:
        # note: the order of creation, configuration & activation here is critical
        # Ensure that any modifications to the _CFG is also made in configure_services
        insert_hdfs_replication_factor(nodes)

        logging.info("Creating HDFS")
        hdfs = generic_create_service(cluster, _CFG.HDFS_CFG, nodes)

        logging.info("Formatting HDFS name node")
        nn_role = get_role_name(hdfs, "NAMENODE")
        cmds = hdfs.format_hdfs(nn_role)
        for cmd in cmds:
            wait_on_success(cmd)

        logging.info("Creating Zookeeper")
        zoo_k = generic_create_service(cluster, _CFG.ZK_CFG, nodes)

        logging.info("Creating HBase")
        hbase = generic_create_service(cluster, _CFG.HBASE_CFG, nodes)

        logging.info("Creating YARN")
        mapred = generic_create_service(cluster, _CFG.MAPRED_CFG, nodes)

        logging.info("Creating Hive")
        hive = generic_create_service(cluster, _CFG.HIVE_CFG, nodes)
        hive_detail = get_role_vm(nodes, hive, get_role_name(hive, "HIVEMETASTORE"))

        logging.info("Creating Oozie")
        oozie = generic_create_service(cluster, _CFG.OOZIE_CFG, nodes)
        oozie_detail = get_role_vm(nodes, oozie, get_role_name(oozie, "OOZIE_SERVER"))

        logging.info("Creating Hue")
        insert_hue_dependencies(nodes, _CFG.HUE_CFG['config'], hdfs, hbase)
        hue = generic_create_service(cluster, _CFG.HUE_CFG, nodes)

        logging.info("Creating Spark")
        spark = generic_create_service(cluster, _CFG.SPARK_CFG, nodes)

        logging.info("Creating Impala")
        impala = generic_create_service(cluster, _CFG.IMPALA_CFG, nodes)

        # The mysql-server is installed on node-1 (i.e. NAMENODE) and is used for oozie, hive and hue databases.
        # This must be done prior to oozie db creation.
        logging.info("Oozie configured to use MySQL database for logging jobs. Creating mysql-connector-java.jar symlink in /var/lib/oozie/ directory.")
        create_mysql_connector_symlink(user, key, oozie_detail['public_addr'], '/var/lib/oozie')

        logging.info("Create Oozie db")
        wait_on_success(oozie.create_oozie_db())

        logging.info("Hive configured to use MySQL database for logging jobs. Creating mysql-connector-java.jar symlink in /var/lib/hive/ directory.")
        create_mysql_connector_symlink(user, key, hive_detail['public_addr'], '/var/lib/hive')

        # This must be done prior to hive metastore db creation.
        logging.info("Creating /tmp for Hive")
        create_hive_tmp(user, key, hive_detail['public_addr'])

        logging.info("Creating Hive metastore database tables")
        wait_on_success(hive.create_hive_metastore_tables())

        logging.info("Starting HDFS")
        wait_on_success(hdfs.start())

        logging.info("Starting Zookeeper")
        wait_on_success(zoo_k.start())

        logging.info("Create HBase root")
        wait_on_success(hbase.create_hbase_root())

        logging.info("Install Oozie sharelib")
        wait_on_success(oozie.install_oozie_sharelib())

        logging.info("Deploying client config")
        wait_on_success(cluster.deploy_client_config())

        logging.info("Creating directories for YARN")
        create_hdfs_dirs(mapred)

        logging.info("Starting YARN")
        wait_on_success(mapred.start())

        logging.info("Starting HBase")
        wait_on_success(hbase.start())

        if ha_enabled:
            logging.info("Enable HA for services")
            enable_hdfs_ha(nodes, hdfs, _CFG.ZK_CFG['name'])

        logging.info("Creating Hive Warehouse directory")
        wait_on_success(hive.create_hive_warehouse())

        logging.info("Starting Hive")
        wait_on_success(hive.start())

        logging.info("Starting Oozie")
        wait_on_success(oozie.start())

        logging.info("Starting Hue")
        wait_on_success(hue.start())

        logging.info("Starting Spark")
        wait_on_success(spark.service_command_by_name('CreateSparkUserDirCommand'))
        wait_on_success(spark.service_command_by_name('CreateSparkHistoryDirCommand'))
        wait_on_success(spark.start())

        logging.info("Starting Impala")
        wait_on_success(impala.create_impala_user_dir())

        wait_on_success(impala.create_impala_catalog_database_tables())
        wait_on_success(impala.start())


    except Exception:
        logging.error("Error while creating services", exc_info=True)
        raise

    return {
        'hdfs': hdfs,
        'zookeeper': zoo_k,
        'mapred': mapred,
        'hbase': hbase,
        'hive': hive,
        'oozie': oozie,
        'hue': hue,
        'spark': spark,
        'impala': impala}


def setup_hadoop(
        cm_api,
        user,
        nodes,
        key_name,
        cluster_name,
        cm_username='admin',
        cm_password='admin',
        parcel_repo=None,
        parcel_version=None,
        anaconda_repo=None,
        anaconda_version=None):

    ha_enabled = _CFG.isHA_enabled

    try:
        api, cloudera_manager = connect(cm_api, 'admin', 'admin')
        if cm_username == 'admin':
            logging.info("Updating admin login password")
            admin_user = api.get_user('admin')
            admin_user.password = cm_password
            users.update_user(api, admin_user)
        else:
            logging.info("Updating admin login user to %s", cm_username)
            api.create_user(cm_username, cm_password, ['ROLE_ADMIN'])

        api, cloudera_manager = connect(cm_api, cm_username, cm_password)
        if cm_username != 'admin':
            logging.info("Deleting old admin login user")
            api.delete_user('admin')
    except:
        logging.info("Admin login user already configured")
        api, cloudera_manager = connect(cm_api, cm_username, cm_password)

    logging.info("Waiting for CM API to become contactable")
    pause_until_api_up(api)

    # There are several ways to add hosts to a cluster, this is the only one that
    # works reliably - introduce hosts & let CM handle installation of agents
    logging.info("Installing hosts")
    new_nodes = create_hosts(api, cloudera_manager, user, nodes, key_name)
    assign_host_ids(api, nodes)

    if len(new_nodes) == 0:
        # no new nodes, reapply config to existing ones
        cluster_action = 'reapply_config'
    elif len(new_nodes) == len(nodes):
        # all new nodes, create new cluster
        cluster_action = 'create_new'
    else:
        # some new nodes, expand cluster onto them
        cluster_action = 'expand'

    if cluster_action == 'create_new':
        # CMS creation is handled slightly differently from other services and must
        # be done prior to cluster creation
        logging.info("Creating CMS")
        cms = create_cms(cloudera_manager, nodes)
        logging.info("Creating cluster")
        cluster = create_cluster(api, cluster_name)
    elif cluster_action == 'expand':
        logging.info("Expanding cluster")
        cluster = api.get_cluster(cluster_name)
        # pylint: disable=E1103
        cluster.add_hosts([h['id'] for h in new_nodes])
    elif cluster_action == 'reapply_config':
        cluster = api.get_cluster(cluster_name)

    if cluster_action == 'create_new' or cluster_action == 'expand':
        # Once we have a cluster and a set of hosts with installed agents, we need
        # to install the correct CDH parcel via the download/distribute/activate
        logging.info("Downloading, distributing and activating parcels")
        install_parcel(cloudera_manager, cluster, 'CDH', parcel_repo, parcel_version)
        
        # to install Anaconda parcels
        logging.info("Downloading anaconda parcels")
        if anaconda_repo is not None and anaconda_version is not None:
            install_parcel(cloudera_manager, cluster, 'Anaconda', anaconda_repo, anaconda_version)

    if cluster_action == 'create_new':
        # Some services are sensitive to perceived health so CMS needs to be started
        # before everything else
        logging.info("Starting CMS")
        wait_on_success(cms.start())

        logging.info("Creating, configuring and starting Hadoop services")
        services = create_services(user, key_name, cluster, nodes, ha_enabled)
        # there isn't much space for parcels but we know we are not going to
        # install any so it's safe to disable this warning
        cloudera_manager.update_all_hosts_config(_CFG.CM_CFG['hosts_config'])
        # Install system shared libs into defined deployment path
        setup_sharedlib(nodes, user, key_name, services['hdfs'], cm_api)

        # For CORONA-3045 sometimes CMS can't find an active namenode until
        # after a restart even though everything is actually fine
        logging.info("Restarting cloudera monitors")
        wait_on_success(cms.restart())
    elif cluster_action == 'expand':
        logging.info("Adding Hadoop services to new nodes")
        expand_services(cluster, new_nodes)
    elif cluster_action == 'reapply_config':
        logging.info("Re-applying hadoop config to all nodes")
        configure_services(cloudera_manager, cluster, nodes)

def setup_sharedlib(nodes, user, key_name, hdfs, cm_api):
    # Get the namenode private ip address
    nn_role = get_role_name(hdfs, "HTTPFS")
    nnode_detail = get_role_vm(nodes, hdfs, nn_role)
    cmd_config = {
        'host': cm_api,
        'ssh_username': user,
        'ssh_pem_file': key_name,
        'ssh_commands': [
            ['python', '/tmp/install_sharedlib.py', '-n', nnode_detail['private_addr']]
        ]
    }
    setup_remotehost(cmd_config)


def setup_remotehost(config):
    shell = spur.SshShell(hostname=config['host'],
                          username=config['ssh_username'],
                          private_key_file=config['ssh_pem_file'],
                          missing_host_key=spur.ssh.MissingHostKey.accept)
    with shell:
        for ssh_command in config['ssh_commands']:
            logging.info('Host - %s: Command - %s', config['host'], ssh_command)
            try:
                result = shell.run(ssh_command)
                logging.debug(string.join(ssh_command, " ") + " - output: " + result.output)
            except spur.results.RunProcessError as exception:
                logging.error(string.join(ssh_command, " ") + " - error: " + exception.stderr_output)
