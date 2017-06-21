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

logging.basicConfig(filename=DEFAULT_LOG_FILE,
                    level=logging.DEBUG,
                    format='%(asctime)s - %(levelname)s - %(message)s')

def setup_hadoop(
        ambari_host,
        nodes,
        cluster_name,
        ambari_username='admin',
        ambari_password='admin',
        hdp_core_stack_repo=None,
        hdp_utils_stack_repo=None):

    logging.info("setup_hadoop:")
    logging.info(ambari_host)
    logging.info(nodes)
    logging.info(cluster_name)
    logging.info(ambari_username)
    logging.info(ambari_password)
    logging.info(hdp_core_stack_repo)
    logging.info(hdp_utils_stack_repo)

    ambari_api = 'http://%s:8080/api/v1' % ambari_host
    headers = {'X-Requested-By': ambari_username}
    auth = (ambari_username, ambari_password)
    logging.info("Waiting for Ambari API to be up")
    api_up = False
    for _ in xrange(120):
        try:
            logging.info("Checking API availability....")
            api_response = requests.get("%s/hosts" % ambari_api, timeout=5, auth=auth, headers=headers)
            logging.debug("%s", api_response.text)
            api_up = True
            break
        except Exception:
            logging.warning("API is not up")
            time.sleep(5)

    def exit_setup(error_message):
        logging.error(error_message)
        raise Exception(error_message)

    if api_up is False:
        exit_setup("The API did not come up: %s" % ambari_api)

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

    logging.info("Creating blueprint")
    blueprint = json.loads(_CFG.BLUEPRINT % {'cluster_name': cluster_name})

    logging.info("Determining HDFS replication factor")
    hdfs_repl_factor = min(3, sum(1 for n in nodes if n["type"] == "DATANODE"))
    logging.info("Setting HDFS replication factor to %s", hdfs_repl_factor)
    for config in blueprint['configurations']:
        if 'hdfs-site' in config:
            config['hdfs-site']['properties']['dfs.replication'] = hdfs_repl_factor

    logging.debug('%s', json.dumps(blueprint))
    blueprint_post_uri = '%s/blueprints/pnda-blueprint' % ambari_api
    blueprint_response = requests.post(blueprint_post_uri, json.dumps(blueprint), auth=auth, headers=headers)
    logging.info('Response to blueprint creation %s: %s', blueprint_post_uri, blueprint_response.status_code)
    logging.info(blueprint_response.text)

    host_group_names = [item['name'] for item in blueprint['host_groups']]
    logging.info('Detected host groups %s in blueprint', json.dumps(host_group_names))

    cluster_instance_def = {
        "blueprint" : "pnda-blueprint",
        "default_password" : ambari_password,
        "host_groups" :[{"name" : host_group, "hosts" : [{"fqdn" : node['host_name']} for node in nodes if node['type'] == host_group]} for host_group in host_group_names]
        }
    logging.debug('%s', json.dumps(cluster_instance_def))

    blueprint_instance_post_uri = '%s/clusters/%s' % (ambari_api, cluster_name)
    cluster_response = requests.post(blueprint_instance_post_uri, json.dumps(cluster_instance_def), auth=auth, headers=headers)
    logging.info(cluster_response.text)
    logging.info('Response to cluster creation %s: %s', blueprint_instance_post_uri, cluster_response.status_code)
    status_tracking_uri = cluster_response.json()['href']

    def wait_on_cmd(tracking_uri, msg):
        logging.info('Waiting for %s...', msg)
        progress_percent = 0
        while progress_percent < 100:
            time.sleep(5)
            status_reponse = requests.get(tracking_uri, auth=auth, headers=headers)
            logging.debug(status_reponse.json()['Requests'])
            cmd_status = status_reponse.json()['Requests']['request_status']
            progress_percent = int(status_reponse.json()['Requests']['progress_percent'])
            logging.info('Progress for %s: %s%% - %s', tracking_uri, progress_percent, cmd_status)
        return cmd_status

    def stop_all_services():
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
        stop_response = requests.put('%s/clusters/%s/services' % (ambari_api, cluster_name), json.dumps(stop_command), auth=auth, headers=headers)
        logging.info('Response to stop command %s: %s', '/clusters/%s/services' % cluster_name, stop_response.status_code)
        logging.info(stop_response.text)
        if stop_response.status_code == 202:
            wait_on_cmd(stop_response.json()['href'], 'services to be stopped by Ambari')

    def start_all_services():
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
        start_response = requests.put('%s/clusters/%s/services' % (ambari_api, cluster_name), json.dumps(start_command), auth=auth, headers=headers)
        logging.info('Response to start command %s: %s', '/clusters/%s/services' % cluster_name, start_response.status_code)
        logging.info(start_response.text)
        if start_response.status_code == 202:
            wait_on_cmd(start_response.json()['href'], 'services to be started by Ambari')

    blueprint_status = wait_on_cmd(status_tracking_uri, "blueprint to be instantiated by Ambari")

    if blueprint_status == 'COMPLETED':
        logging.info('Ambari blueprint instantiation succeeded: %s', blueprint_status)
    else:
        logging.info('Ambari blueprint instantiation did not succeed, attempting to start services manually: %s', blueprint_status)
        # If there was an error starting the services try restarting them, this often succeeeds after a short wait
        stop_all_services()
        start_all_services()

    # Even if there were no errors starting the services try issuing a start just to make sure everything is running
    time.sleep(60)
    start_all_services()
