"""
Name:       hdp_setup
Purpose:    Drives the Ambari API to create a cluster and configure
            the various component services such as HDFS, HBase etc

Author:     PNDA team

Created:    15/05/2017
"""

import logging
import time
import json
import requests

# Import Flavor configuration file
import cfg_flavor as _CFG

DEFAULT_LOG_FILE = '/var/log/pnda/hadoop_setup.log'
PNDA_BLUEPRINT_NAME = "pnda-blueprint"

logging.basicConfig(filename=DEFAULT_LOG_FILE,
                    level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')

def wait_on_cmd(tracking_uri, msg, cluster_name, ambari_api, auth, headers):
    '''
    Wait for ambari to complete running a command. A command is complete when the
    progress_percent value reaches 100.
    '''
    logging.debug('Waiting for %s...', msg)
    progress_percent = 0
    task_count = 0
    task_state_by_id = {}
    while progress_percent < 100 or task_count == 0:
        time.sleep(5)
        status_reponse = requests.get('%s%s' % (tracking_uri, '?fields=tasks/Tasks/status,tasks/Tasks/command,tasks/Tasks/role,tasks/Tasks/host_name,Requests'),
                                      auth=auth, headers=headers)
        response_json = status_reponse.json()
        request_info = response_json['Requests']
        logging.debug(json.dumps(request_info))
        cmd_status = request_info['request_status']
        task_count = request_info['task_count']
        progress_percent = int(request_info['progress_percent'])
        logging.info('%s%% of %s tasks - %s', progress_percent, task_count, cmd_status)
        # Log some info on any failed tasks:
        if 'tasks' in response_json:
            for task in response_json['tasks']:
                task_info = task['Tasks']
                task_id = task_info['id']
                status = task_info['status']

                # Only log this task if we don't yet know about it or we do, but its status has changed
                if task_id not in task_state_by_id or task_state_by_id[task_id] != status:
                    task_state_by_id[task_id] = status
                    logging.info('%s: %s %s on %s', status, task_info['command'], task_info['role'], task_info['host_name'])
                    request_id = task_info['request_id']
                    if status == 'FAILED':
                        logging.warn('Failed ambari task detected, fetching details')
                        task_status_response = requests.get('%s/clusters/%s/requests/%s/tasks/%s' % (ambari_api, cluster_name, request_id, task_id),
                                                            auth=auth, headers=headers)
                        logging.info(task_status_response.json())
    return cmd_status

def stop_all_services(cluster_name, ambari_api, auth, headers):
    '''
    Stop all hadoop services
    '''
    logging.info("Stopping all services")
    stop_command = {
        "RequestInfo": {
            "context": "_PARSE_.STOP.ALL_SERVICES",
            "operation_level": {
                "level": "CLUSTER",
                "cluster_name": cluster_name
            }
        },
        "Body": {
            "ServiceInfo": {
                "state": "INSTALLED"
            }
        }
    }
    stop_uri = '%s/clusters/%s/services' % (ambari_api, cluster_name)
    stop_response = requests.put(stop_uri, json.dumps(stop_command), auth=auth, headers=headers)
    logging.debug(stop_response.text)
    if stop_response.status_code == 202:
        wait_on_cmd(stop_response.json()['href'], 'services to be stopped by Ambari', cluster_name, ambari_api, auth, headers)

def start_all_services(cluster_name, ambari_api, auth, headers):
    '''
    Start all hadoop services
    '''
    logging.info("Starting all services")
    start_command = {
        "RequestInfo": {
            "context": "_PARSE_.START.ALL_SERVICES",
            "operation_level": {
                "level": "CLUSTER",
                "cluster_name": cluster_name
            }
        },
        "Body": {
            "ServiceInfo": {
                "state": "STARTED"
            }
        }
    }
    start_uri = '%s/clusters/%s/services' % (ambari_api, cluster_name)
    start_response = requests.put(start_uri, json.dumps(start_command), auth=auth, headers=headers)
    logging.debug(start_response.text)
    if start_response.status_code == 202:
        return wait_on_cmd(start_response.json()['href'], 'services to be started by Ambari', cluster_name, ambari_api, auth, headers)
    return 'COMPLETED'

def exit_setup(error_message):
    '''
    log an error and exit the program
    '''
    logging.error(error_message)
    raise Exception(error_message)

def get_new_nodes(all_nodes, cluster_name, ambari_api, auth, headers):
    '''
    Work out which entries in all_nodes are datanodes that are not
    currently in the cluster.
    '''
    logging.info("Checking for new nodes")

    existing_hosts_response = requests.get('%s/clusters/%s/services/HDFS/components/DATANODE?fields=host_components' %
                                           (ambari_api, cluster_name), auth=auth, headers=headers)
    if existing_hosts_response.status_code == 200:
        existing_hosts = [host['HostRoles']['host_name'] for host in existing_hosts_response.json()['host_components']]
    else:
        existing_hosts = []

    logging.debug("Existing hosts are: %s", json.dumps(existing_hosts))
    new_nodes = [node for node in all_nodes if node['host_name'] not in existing_hosts and node['type'] == 'DATANODE']
    logging.info("New nodes are: %s", json.dumps(new_nodes))
    return new_nodes

def set_hdf_repl_factor(blueprint, nodes):
    '''
    Set the HDFS replication factor in the blueprint definition based on how
    many datanodes there are: min(3, DATANODE_COUNT)
    '''
    logging.debug("Determining HDFS replication factor")
    hdfs_repl_factor = min(3, sum(1 for n in nodes if n["type"] == "DATANODE"))
    logging.info("Setting HDFS replication factor to %s", hdfs_repl_factor)
    for config in blueprint['configurations']:
        if 'hdfs-site' in config:
            config['hdfs-site']['properties']['dfs.replication'] = hdfs_repl_factor

def create_new_cluster(nodes, cluster_name, hdp_core_stack_repo, hdp_utils_stack_repo, ambari_api, auth, headers):
    '''
    Create a new cluster, will fail if a cluster with this name already exists.
     - Adds the stack repos
     - Creates the blueprint definition
     - Creates the cluster instance
     - Creates ambari views for oozie and HDFS
    '''
    logging.info("Creating new cluster")

    ### Add HDP stack repositories ###
    logging.info("Configuring Ambari to use HDP stack repos")

    if 'ubuntu14' in hdp_core_stack_repo:
        hdp_os_type = 'ubuntu14'
    elif 'centos7' in hdp_core_stack_repo:
        hdp_os_type = 'redhat7'
    else:
        exit_setup('Expected ubuntu14 or centos7 in hdp_core_stack_repo but found: %s' % hdp_core_stack_repo)

    repo_definition = {
        "RepositoryVersions" : {
            "display_name" : "HDP",
            "repository_version" : "2.6"
        },
        "operating_systems" : [
            {
                "OperatingSystems" : {
                    "os_type" : hdp_os_type,
                    "stack_name" : "HDP",
                    "stack_version" : "2.6"
                },
                "repositories" : [
                    {
                        "Repositories" : {
                            "base_url" : hdp_core_stack_repo,
                            "os_type" : hdp_os_type,
                            "repo_id" : "HDP-2.6",
                            "repo_name" : "HDP",
                            "unique" : False
                        }
                    },
                    {
                        "Repositories" : {
                            "base_url" : hdp_utils_stack_repo,
                            "os_type" : hdp_os_type,
                            "repo_id" : "HDP-UTILS-1.1.0.21",
                            "repo_name" : "HDP-UTILS",
                            "unique" : False
                        }
                    }
                ]
            }
        ]
    }
    logging.info("Registering repos: %s", repo_definition)
    repo_response = requests.post('%s/stacks/HDP/versions/2.6/repository_versions' % ambari_api, json.dumps(repo_definition), auth=auth, headers=headers)
    if repo_response.status_code != 201:
        exit_setup(repo_response.text)
    logging.debug("Registered repos")

    ### Create blueprint ###
    logging.info("Loading blueprint")
    blueprint = json.loads(_CFG.BLUEPRINT % {'cluster_name': cluster_name})
    set_hdf_repl_factor(blueprint, nodes)

    logging.debug("Blueprint to be used:")
    logging.debug('%s', json.dumps(blueprint))

    logging.info("Creating blueprint")
    blueprint_post_uri = '%s/blueprints/%s' % (ambari_api, PNDA_BLUEPRINT_NAME)
    blueprint_response = requests.post(blueprint_post_uri, json.dumps(blueprint), auth=auth, headers=headers)
    logging.debug(blueprint_response.text)

    logging.debug("Calculating cluster role mappings")
    host_group_names = [item['name'] for item in blueprint['host_groups']]
    logging.debug('Detected host groups %s in blueprint', json.dumps(host_group_names))

    cluster_instance_def = {
        "blueprint" : PNDA_BLUEPRINT_NAME,
        "default_password" : auth[1],
        "host_groups" :[{"name" : host_group, "hosts" : [{"fqdn" : node['host_name']} for node in nodes if node['type'] == host_group]}
                        for host_group in host_group_names]
    }
    logging.debug("Cluster role mappings to be used:")
    logging.debug('%s', json.dumps(cluster_instance_def))

    ### Create instance of bluerprint ###
    logging.info("Creating cluster instance")
    blueprint_instance_post_uri = '%s/clusters/%s' % (ambari_api, cluster_name)
    cluster_response = requests.post(blueprint_instance_post_uri, json.dumps(cluster_instance_def), auth=auth, headers=headers)
    logging.debug(cluster_response.text)
    status_tracking_uri = cluster_response.json()['href']

    blueprint_status = wait_on_cmd(status_tracking_uri, "blueprint to be instantiated by Ambari", cluster_name, ambari_api, auth, headers)

    ### Check everything started and retry if needed ###
    if blueprint_status == 'COMPLETED':
        logging.info('Ambari blueprint instantiation succeeded')
    else:
        logging.warning('Ambari blueprint instantiation did not succeed, attempting to start services manually: %s', blueprint_status)
        # If there was an error starting the services try restarting them, this often succeeeds after a short wait
        stop_all_services(cluster_name, ambari_api, auth, headers)
        start_all_services(cluster_name, ambari_api, auth, headers)

    # Even if there were no errors starting the services try issuing a start just to make sure everything is running
    time.sleep(60)
    final_start_result = start_all_services(cluster_name, ambari_api, auth, headers)
    # If this fails then abort here because something didn't come up
    if final_start_result != 'COMPLETED':
        exit_setup('Did not manage to start all services successfully')

    ### Confgure disk space thresholds ###
    logging.info('Configuring alert thresholds')
    disk_alert_uri = requests.get('%s/clusters/%s/alert_definitions?AlertDefinition/name=ambari_agent_disk_usage' %
                                  (ambari_api, cluster_name), auth=auth, headers=headers).json()['items'][0]['href']
    disk_alert_def = requests.get(disk_alert_uri, auth=auth, headers=headers).json()
    for parameter in disk_alert_def['AlertDefinition']['source']['parameters']:
        if parameter['name'] == 'minimum.free.space':
            parameter['value'] = 1024*1024*1024
        elif parameter['name'] == 'percent.used.space.warning.threshold':
            parameter['value'] = 80.0
        elif parameter['name'] == 'percent.free.space.critical.threshold':
            parameter['value'] = 90.0
    disk_alert_def.pop('href', None)
    requests.put(disk_alert_uri, json.dumps(disk_alert_def), auth=auth, headers=headers)

    ### Disable some alerts - these cause problems by often showing up on newly provisioned clusters, when everything is actually OK ###
    ###                       an operator could consider re-enabling these after the platform is stable                              ###
    def disable_alert(alert_name):
        alert_uri = requests.get('%s/clusters/%s/alert_definitions?AlertDefinition/name=%s' %
                                 (ambari_api, cluster_name, alert_name), auth=auth, headers=headers).json()['items'][0]['href']
        alert_def = requests.get(alert_uri, auth=auth, headers=headers).json()
        alert_def['AlertDefinition']['enabled'] = False
        alert_def.pop('href', None)
        requests.put(alert_uri, json.dumps(alert_def), auth=auth, headers=headers)
    disable_alert('ams_metrics_collector_autostart')
    disable_alert('ambari_server_stale_alerts')

    ### Create Ambari views ###
    logging.info("Creating Ambari HDFS files view")
    cluster_id = requests.get('%s/clusters/%s' % (ambari_api, cluster_name), auth=auth, headers=headers).json()['Clusters']['cluster_id']
    hfds_files_view_def = {
        "ViewInstanceInfo" : {
            "cluster_handle" : int(cluster_id),
            "description" : "Files View with full access as hdfs super user",
            "label" : "Files View (Super User)",
            "properties" : {
                "webhdfs.username": "hdfs",
                "webhdfs.auth": None,
                "tmp.dir": "/user/hdfs/files-view/tmp",
                "view.conf.keyvalues": None
            }
        }
    }
    create_files_view_uri = '%s/views/FILES/versions/1.0.0/instances/PNDA_FILES_SU' % ambari_api
    create_files_view_response = requests.post(create_files_view_uri, json.dumps(hfds_files_view_def), auth=auth, headers=headers)
    logging.debug(create_files_view_response.text)

    logging.info("Creating Ambari Oozie workflow view")
    oozie_workflow_view_def = {
        "ViewInstanceInfo" : {
            "cluster_handle" : int(cluster_id),
            "description" : "Oozie Workflow View",
            "label" : "Oozie Workflow View",
            "properties" :     {
                "webhdfs.username": "hdfs",
                "webhdfs.auth": None,
                "view.conf.keyvalues": None
            }
        }
    }
    create_wf_view_uri = '%s/views/WORKFLOW_MANAGER/versions/1.0.0/instances/PNDA_WORKFLOW' % ambari_api
    create_wf_view_response = requests.post(create_wf_view_uri, json.dumps(oozie_workflow_view_def), auth=auth, headers=headers)
    logging.debug(create_wf_view_response.text)

def update_cluster_config(nodes, cluster_name, ambari_api, auth, headers):
    '''
    Apply updated config to a cluster.
    Does not use Blueprint API as changes cannot be applied in this way using blueprints,
    instead the config is loaded out of the blueprint and manually applied where changes are detected.
    '''
    logging.info("Updating cluster configuration")

    ### Load properties out of blueprint definition ###
    blueprint = json.loads(_CFG.BLUEPRINT % {'cluster_name': cluster_name})
    set_hdf_repl_factor(blueprint, nodes)
    blueprint_config = {}
    for requested_config in blueprint['configurations']:
        requested_config_type = list(requested_config)[0]
        logging.debug('Caching blueprint config for %s', requested_config_type)
        blueprint_config[requested_config_type] = requested_config[requested_config_type]['properties']

    ### Ask Ambari which config set is active for each type of config file ###
    configurations_response = requests.get('%s/clusters/%s?fields=Clusters/desired_configs' % (ambari_api, cluster_name), auth=auth, headers=headers)
    desired_configs = configurations_response.json()['Clusters']['desired_configs']
    for config_type in desired_configs:
        logging.debug('Considering updated config for %s', config_type)
        if config_type not in blueprint_config:
            continue

        ### Retrieve currently active configuration for this config file ###
        config_tag = desired_configs[config_type]['tag']
        logging.debug('Retrieving existing config for %s@%s', config_type, config_tag)
        configuration_type_response = requests.get('%s/clusters/%s/configurations?type=%s&tag=%s' %
                                                   (ambari_api, cluster_name, config_type, config_tag), auth=auth, headers=headers)
        properties_set = configuration_type_response.json()['items'][0]['properties']

        ### Update the property set with what was loaded from the blueprint ###
        new_props = blueprint_config[config_type]

        any_updates = False
        for new_prop in new_props:

            if new_prop not in properties_set:
                logging.debug('%s is new addition', new_prop)
                any_updates = True
            elif (str(new_props[new_prop]) != str(properties_set[new_prop])) and 'SECRET:' not in properties_set[new_prop]:
                logging.debug('%s is new value %s (old) != %s (new)', new_prop, properties_set[new_prop], new_props[new_prop])
                any_updates = True

            properties_set[new_prop] = new_props[new_prop]

        ### If any changes have been made, apply the new config ###
        if any_updates:
            logging.info('Updating config for %s with new value', config_type)
            update_config_command = {
                "Clusters": {
                    "desired_config": {
                        "type": config_type,
                        "tag": "version%s" % int(round(time.time() * 1000)),
                        "properties": properties_set,
                        "service_config_version_note":"Config generated by hdp_setup.py from salt template"
                    }
                }
            }
            update_config_response = requests.put('%s/clusters/%s' % (ambari_api, cluster_name), json.dumps(update_config_command), auth=auth, headers=headers)
            logging.debug(update_config_response.text)


def expand_cluster(new_nodes, cluster_name, ambari_api, auth, headers):
    '''
    Apply updated config to a cluster from a blueprint template.
    Only updates config where changes are detected.
    '''
    logging.info("Expanding cluster")
    blueprint_expand_post_uri = '%s/clusters/%s/hosts' % (ambari_api, cluster_name)
    expansion_def = [{"blueprint" : PNDA_BLUEPRINT_NAME, "host_group" : "DATANODE", "host_name" : node['host_name']} for node in new_nodes]
    expand_response = requests.post(blueprint_expand_post_uri, json.dumps(expansion_def), auth=auth, headers=headers)
    logging.debug(expand_response.text)
    expand_tracking_uri = expand_response.json()['href']
    expand_status = wait_on_cmd(expand_tracking_uri, "blueprint to be applied to new nodes by Ambari", cluster_name, ambari_api, auth, headers)
    logging.info("Expansion finished, result: %s", expand_status)

def wait_for_api_up(ambari_api, auth, headers):
    check_api_response_code = 0
    attempts = 60
    while check_api_response_code != 200 and attempts > 0:
        try:
            logging.debug('Waiting for API to come up')
            time.sleep(5)
            attempts -= 1
            check_api_response = requests.get('%s/users' % (ambari_api), auth=auth, headers=headers)
            check_api_response_code = check_api_response.status_code
        except:
            logging.debug('API is not up yet')
            check_api_response_code = 0

def setup_hadoop(
        ambari_host,
        nodes,
        cluster_name,
        ambari_username='admin',
        ambari_password='admin',
        hdp_core_stack_repo=None,
        hdp_utils_stack_repo=None):
    '''
    Drives Ambari API to configure hadoop cluster
    Runs in one of three modes:
     - create new cluster: when there is no existing cluster
     - update config: when there are no new nodes to add
     - expand cluster: when there are some new nodes to add
    '''
    logging.info("setup_hadoop: configuring hadoop services via Ambari API")
    logging.info("Ambari host: %s", ambari_host)
    logging.debug("Ambari username: %s", ambari_username)
    logging.debug("Ambari password: %s", ambari_password)
    logging.info("Cluster name: %s", cluster_name)
    logging.info("Cluster nodes: %s", json.dumps(nodes))
    logging.info("Ambari core repo: %s", hdp_core_stack_repo)
    logging.info("Ambari utils repo: %s", hdp_utils_stack_repo)

    ambari_api = 'http://%s:8080/api/v1' % ambari_host
    headers = {'X-Requested-By': 'admin'}
    auth = ('admin', 'admin')

    wait_for_api_up(ambari_api, auth, headers)

    get_admin_user_response = requests.get('%s/users/admin' % (ambari_api), auth=auth, headers=headers)
    if get_admin_user_response.status_code != 200 or (ambari_username == 'admin' and ambari_password == 'admin'):
        # Either:
        #     we couldn't access ambari with admin/admin in which case we already set the password. If we already set
        #     the login to something else and this is now rerunning with other credentials we can't set them anyway, becaue
        #     we don't know what the old password was. In this case, the changes should be manually applied via the ambari UI
        #     by an operator who knows what the old password was.
        # or:
        #     we could access ambari with admin/admin, but aren't planning on changing it
        logging.info("Admin login user is already configured")
    else:
        if ambari_username == 'admin':
            # The username is still admin, but the password is not admin so change it
            logging.info("Updating admin login password")
            update_pwd_command = {
                "Users": {
                    "user_name": ambari_username,
                    "old_password": "admin",
                    "password": ambari_password
                }
            }
            requests.put('%s/users/%s' % (ambari_api, ambari_username), json.dumps(update_pwd_command), auth=auth, headers=headers)
        else:
            # The username is something other than admin so create a new user, then delete the existing admin user.
            logging.info("Updating admin login user to %s", ambari_username)
            create_user_command = {
                "Users/user_name": ambari_username,
                "Users/password":  ambari_password,
                "Users/active": True,
                "Users/admin": True
            }
            requests.post('%s/users' % (ambari_api), json.dumps(create_user_command), auth=auth, headers=headers)
            headers = {'X-Requested-By': ambari_username}
            auth = (ambari_username, ambari_password)
            logging.info("Deleting old admin login user")
            requests.delete('%s/users/admin' % (ambari_api), auth=auth, headers=headers)

    headers = {'X-Requested-By': ambari_username}
    auth = (ambari_username, ambari_password)

    new_nodes = get_new_nodes(nodes, cluster_name, ambari_api, auth, headers)

    if len(new_nodes) == 0:
        # no new nodes, reapply config to existing ones
        update_cluster_config(nodes, cluster_name, ambari_api, auth, headers)
    elif len(new_nodes) == len([node for node in nodes if node['type'] == 'DATANODE']):
        # all new nodes, create new cluster
        create_new_cluster(nodes, cluster_name, hdp_core_stack_repo, hdp_utils_stack_repo, ambari_api, auth, headers)
    else:
        # some new nodes, expand cluster onto them
        expand_cluster(new_nodes, cluster_name, ambari_api, auth, headers)
        # config might also have been updated so make sure that is up to date too
        update_cluster_config(nodes, cluster_name, ambari_api, auth, headers)

    logging.info("HDP setup finished")
