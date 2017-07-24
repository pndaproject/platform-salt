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

def wait_on_cmd(tracking_uri, msg, auth, headers):
    logging.debug('Waiting for %s...', msg)
    progress_percent = 0
    while progress_percent < 100:
        time.sleep(5)
        status_reponse = requests.get(tracking_uri, auth=auth, headers=headers)
        logging.debug(status_reponse.json()['Requests'])
        cmd_status = status_reponse.json()['Requests']['request_status']
        progress_percent = int(status_reponse.json()['Requests']['progress_percent'])
        logging.debug('Progress for %s: %s%% - %s', tracking_uri, progress_percent, cmd_status)
    return cmd_status

def stop_all_services(cluster_name, ambari_api, auth, headers):
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
    logging.debug('Response to stop command %s: %s', stop_uri, stop_response.status_code)
    logging.debug(stop_response.text)
    if stop_response.status_code == 202:
        wait_on_cmd(stop_response.json()['href'], 'services to be stopped by Ambari', auth, headers)

def start_all_services(cluster_name, ambari_api, auth, headers):
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
    logging.debug('Response to start command %s: %s', start_uri, start_response.status_code)
    logging.debug(start_response.text)
    if start_response.status_code == 202:
        wait_on_cmd(start_response.json()['href'], 'services to be started by Ambari', auth, headers)

def exit_setup(error_message):
    logging.error(error_message)
    raise Exception(error_message)

def get_new_nodes(all_nodes, cluster_name, ambari_api, auth, headers):
    logging.info("Checking for new nodes")
    existing_hosts = [host['HostRoles']['host_name'] for host in requests.get('%s/clusters/%s/services/HDFS/components/DATANODE?fields=host_components' % (ambari_api, cluster_name), auth=auth, headers=headers).json()['host_components']]
    logging.debug("Existing hosts are: %s", json.dumps(existing_hosts))
    new_nodes = [node for node in all_nodes if node['host_name'] not in existing_hosts and node['type'] == 'DATANODE']
    logging.info("New nodes are: %s", json.dumps(new_nodes))
    return new_nodes

def create_new_cluster(nodes, cluster_name, hdp_core_stack_repo, hdp_utils_stack_repo, ambari_api, auth, headers):
    logging.info("Creating new cluster")
    logging.info("Configuring Ambari to use HDP stack repos")

    if 'ubuntu14' in hdp_core_stack_repo:
        hdp_os_type = 'ubuntu14'
    elif 'centos7' in hdp_core_stack_repo:
        hdp_os_type = 'redhat7'
    else:
        exit_setup('Expected ubuntu14 or centos7 in hdp_core_stack_repo but found: %s' % hdp_core_stack_repo)

    repo_requests = [('%s/stacks/HDP/versions/2.6/operating_systems/%s/repositories/HDP-2.6' % (ambari_api, hdp_os_type),
                      '{"Repositories" : { "base_url" : "%s", "verify_base_url" : true }}' % hdp_core_stack_repo),
                     ('%s/stacks/HDP/versions/2.6/operating_systems/%s/repositories/HDP-UTILS-1.1.0.21' % (ambari_api, hdp_os_type),
                      '{"Repositories" : { "base_url" : "%s", "verify_base_url" : true }}' % hdp_utils_stack_repo)]

    for repo_request in repo_requests:
        logging.debug("Registering repo: %s", repo_request[0])
        repo_response = requests.put(repo_request[0], repo_request[1], auth=auth, headers=headers)
        if repo_response.status_code != 200:
            exit_setup(repo_response.text)
        logging.debug("Registered repo: %s", repo_request[0])

    logging.info("Loading blueprint")
    blueprint = json.loads(_CFG.BLUEPRINT % {'cluster_name': cluster_name})

    logging.debug("Determining HDFS replication factor")
    hdfs_repl_factor = min(3, sum(1 for n in nodes if n["type"] == "DATANODE"))
    logging.info("Setting HDFS replication factor to %s", hdfs_repl_factor)
    for config in blueprint['configurations']:
        if 'hdfs-site' in config:
            config['hdfs-site']['properties']['dfs.replication'] = hdfs_repl_factor

    logging.debug("Blueprint to be used:")
    logging.debug('%s', json.dumps(blueprint))

    logging.info("Creating blueprint")
    blueprint_post_uri = '%s/blueprints/%s' % (ambari_api, PNDA_BLUEPRINT_NAME)
    blueprint_response = requests.post(blueprint_post_uri, json.dumps(blueprint), auth=auth, headers=headers)
    logging.debug('Response to blueprint creation %s: %s', blueprint_post_uri, blueprint_response.status_code)
    logging.debug(blueprint_response.text)

    logging.debug("Calculating cluster role mappings")
    host_group_names = [item['name'] for item in blueprint['host_groups']]
    logging.debug('Detected host groups %s in blueprint', json.dumps(host_group_names))

    cluster_instance_def = {
        "blueprint" : PNDA_BLUEPRINT_NAME,
        "default_password" : auth[1],
        "host_groups" :[{"name" : host_group, "hosts" : [{"fqdn" : node['host_name']} for node in nodes if node['type'] == host_group]} for host_group in host_group_names]
    }
    logging.debug("Cluster role mappings to be used:")
    logging.debug('%s', json.dumps(cluster_instance_def))

    logging.info("Creating cluster instance")
    blueprint_instance_post_uri = '%s/clusters/%s' % (ambari_api, cluster_name)
    cluster_response = requests.post(blueprint_instance_post_uri, json.dumps(cluster_instance_def), auth=auth, headers=headers)
    logging.debug('Response to cluster creation %s: %s', blueprint_instance_post_uri, cluster_response.status_code)
    logging.debug(cluster_response.text)
    status_tracking_uri = cluster_response.json()['href']

    blueprint_status = wait_on_cmd(status_tracking_uri, "blueprint to be instantiated by Ambari", auth, headers)

    if blueprint_status == 'COMPLETED':
        logging.info('Ambari blueprint instantiation succeeded')
    else:
        logging.warning('Ambari blueprint instantiation did not succeed, attempting to start services manually: %s', blueprint_status)
        # If there was an error starting the services try restarting them, this often succeeeds after a short wait
        stop_all_services(cluster_name, ambari_api, auth, headers)
        start_all_services(cluster_name, ambari_api, auth, headers)

    # Even if there were no errors starting the services try issuing a start just to make sure everything is running
    time.sleep(60)
    start_all_services(cluster_name, ambari_api, auth, headers)

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
    logging.debug('Response to create files view command %s: %s', create_files_view_uri, create_files_view_response.status_code)
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
    logging.debug('Response to create workflow view command %s: %s', create_wf_view_uri, create_wf_view_response.status_code)
    logging.debug(create_wf_view_response.text)

def update_cluster_config():
    logging.info("Updating cluster configuration")

def expand_cluster(new_nodes, cluster_name, ambari_api, auth, headers):
    logging.info("Expanding cluster")
    blueprint_expand_post_uri = '%s/clusters/%s/hosts' % (ambari_api, cluster_name)
    expansion_def = [{"blueprint" : PNDA_BLUEPRINT_NAME, "host_group" : "DATANODE", "host_name" : node['host_name']} for node in new_nodes]
    expand_response = requests.post(blueprint_expand_post_uri, json.dumps(expansion_def), auth=auth, headers=headers)
    logging.debug('Response to cluster expansion %s: %s', blueprint_expand_post_uri, expand_response.status_code)
    logging.debug(expand_response.text)
    expand_tracking_uri = expand_response.json()['href']
    expand_status = wait_on_cmd(expand_tracking_uri, "blueprint to be applied to new nodes by Ambari", auth, headers)
    logging.info("Expansion finished, result: %s", expand_status)

def setup_hadoop(
        ambari_host,
        nodes,
        cluster_name,
        ambari_username='admin',
        ambari_password='admin',
        hdp_core_stack_repo=None,
        hdp_utils_stack_repo=None):

    logging.info("setup_hadoop: configuring hadoop services via Ambari API")
    logging.info("Ambari host: %s", ambari_host)
    logging.debug("Ambari username: %s", ambari_username)
    logging.debug("Ambari password: %s", ambari_password)
    logging.info("Cluster name: %s", cluster_name)
    logging.info("Cluster nodes: %s", json.dumps(nodes))
    logging.info("Ambari core repo: %s", hdp_core_stack_repo)
    logging.info("Ambari utils repo: %s", hdp_utils_stack_repo)

    ambari_api = 'http://%s:8080/api/v1' % ambari_host
    headers = {'X-Requested-By': ambari_username}
    auth = (ambari_username, ambari_password)

    logging.info("Waiting for Ambari API to be up")
    api_up = False
    for _ in xrange(120):
        try:
            logging.debug("Checking API availability....")
            api_response = requests.get("%s/hosts" % ambari_api, timeout=5, auth=auth, headers=headers)
            logging.debug("%s", api_response.text)
            api_up = True
            logging.debug("API is up")
            break
        except Exception:
            logging.warning("API is not up")
            time.sleep(5)

    if api_up is False:
        exit_setup("The API did not come up: %s" % ambari_api)

    new_nodes = get_new_nodes(nodes, cluster_name, ambari_api, auth, headers)

    if len(new_nodes) == 0:
        # no new nodes, reapply config to existing ones
        update_cluster_config()
    elif len(new_nodes) == len(nodes):
        # all new nodes, create new cluster
        create_new_cluster(nodes, cluster_name, hdp_core_stack_repo, hdp_utils_stack_repo, ambari_api, auth, headers)
    else:
       # some new nodes, expand cluster onto them
       expand_cluster(new_nodes, cluster_name, ambari_api, auth, headers)
       # config might also have been updated so make sure that is up to date too
       update_cluster_config()

    logging.info("HDP setup finished")