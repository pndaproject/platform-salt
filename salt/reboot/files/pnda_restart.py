"""
Name:       pnda_restart
Purpose:    Drives the Cloudera Manager API to detect stopped roles and starts them

Author:     PNDA team

Created:    31/10/2016
"""

import sys
import time
import json
import logging
import traceback
import requests

from cm_api.api_client import ApiResource

def connect_cm(cm_api, cm_username, cm_password):
    api = ApiResource(cm_api, version=11, username=cm_username, password=cm_password)
    hadoop_manager = api.get_cloudera_manager()
    return api, hadoop_manager

def wait_on_command(cmds):
    messages = []
    success = False

    for cmd in cmds:
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

def check_unexpected_stop(service, role):
    try:
        logging.debug('checking %s - %s => desired state: %s, actual state: %s', role.type, role.name, role.roleState, role.entityStatus)
        if role.entityStatus == "DOWN":
            logging.debug('Role process is down: %s - %s', role.type, role.name)
            if role.maintenanceMode is True:
                logging.info('Role process is down, but maintennance mode is enabled: %s - %s',
                             role.type, role.name)
            elif role.roleState == "STARTED":
                logging.info('Role process is down, and is meant to be running: %s - %s',
                             role.type, role.name)
                success, info = wait_on_command(service.restart_roles(role.name))
                if success is False:
                    logging.error('Failed to restart %s - %s. %s', role.type, role.name, json.dumps(info))
                else:
                    logging.info('Restarted %s - %s', role.type, role.name)
            else:
                logging.info('Role process is down, but has been stopped intentionally. %s - %s is %s',
                             role.type, role.name, role.healthSummary)
    except Exception as ex:
        logging.error(traceback.format_exc(ex))

def ambari_request(ambari, uri, body=None):
    hadoop_manager_ip = ambari[0]
    hadoop_manager_username = ambari[1]
    hadoop_manager_password = ambari[2]
    if uri.startswith("http"):
        full_uri = uri
    else:
        full_uri = 'http://%s:8080/api/v1%s' % (hadoop_manager_ip, uri)

    headers = {'X-Requested-By': hadoop_manager_username}
    auth = (hadoop_manager_username, hadoop_manager_password)
    if body is None:
        response = requests.get(full_uri, auth=auth, headers=headers)
    else:
        response = requests.put(full_uri, body, auth=auth, headers=headers)
    logging.debug('Response to command = %s', response.status_code)
    logging.debug(response.text)
    try:
        return response.json()
    except ValueError:
        return None

def wait_on_cmd(ambari, tracking_uri, msg):
    logging.info('Waiting for %s...', msg)
    progress_percent = 0
    while progress_percent < 100:
        time.sleep(5)
        status_reponse = ambari_request(ambari, tracking_uri)
        logging.debug(status_reponse['Requests'])
        cmd_status = status_reponse['Requests']['request_status']
        progress_percent = int(status_reponse['Requests']['progress_percent'])
        logging.info('Progress for %s: %s%% - %s', tracking_uri, progress_percent, cmd_status)
    return cmd_status

def stop_all_services(ambari, cluster_name):
    stop_command = '''{
                            "RequestInfo": {
                                "context": "_PARSE_.STOP.ALL_SERVICES",
                                "operation_level": {
                                    "level": "CLUSTER",
                                    "cluster_name": "%s"
                                }
                            },
                            "Body": {
                                "ServiceInfo": {
                                    "state": "INSTALLED"
                                }
                            }
                    }''' % cluster_name

    response = ambari_request(ambari, '/clusters/%s/services' % (cluster_name), stop_command)
    if response is not None:
        wait_on_cmd(ambari, response['href'], 'services to be stopped by Ambari')

def start_all_services(ambari, cluster_name):
    start_command = '''{
                            "RequestInfo": {
                                "context": "_PARSE_.START.ALL_SERVICES",
                                "operation_level": {
                                    "level": "CLUSTER",
                                    "cluster_name": "%s"
                                }
                            },
                            "Body": {
                                "ServiceInfo": {
                                    "state": "STARTED"
                                }
                            }
                    }''' % cluster_name
    response = ambari_request(ambari, '/clusters/%s/services' % (cluster_name), start_command)
    if response is not None:
        wait_on_cmd(ambari, response['href'], 'services to be started by Ambari')

def main():
    print 'PNDA Watchdog starting'
    with open('properties.json', 'r') as props_file:
        config = json.load(props_file)

    logging.basicConfig(format='%(asctime)s %(levelname)s %(message)s',
                        level=logging.getLevelName(config['log_level']),
                        stream=sys.stderr)

    logging.debug('Config loaded')

    if config['hadoop_distro'] == 'CDH':
        logging.debug('Connecting to Cloudera Manager API on %s', config['cm_host'])
        api, cloudera_manager = connect_cm(config['cm_host'], config['cm_user'], config['cm_pass'])
        logging.info('Connected to Cloudera Manager API')

        logging.debug('Searching for Cluster')
        for cluster_detail in api.get_all_clusters():
            cluster_name = cluster_detail.name
            break

        cluster = api.get_cluster(cluster_name)
        logging.debug('Found cluster %s', cluster_name)
        # pylint: disable=E1103
        cms_service = cloudera_manager.get_service()
        for role in cms_service.get_all_roles():
            check_unexpected_stop(cms_service, role)

        for service in cluster.get_all_services():
            logging.debug('checking %s - %s', service.type, service.name)
            for role in service.get_all_roles():
                check_unexpected_stop(service, role)
    else:
        logging.debug('Connecting to Ambari API on %s', config['cm_host'])
        ambari = (config['cm_host'], config['cm_user'], config['cm_pass'])

        logging.debug('Searching for Cluster')
        cluster_name = ambari_request(ambari, '/clusters')['items'][0]['Clusters']['cluster_name']
        logging.debug('Found cluster %s', cluster_name)

        stop_all_services(ambari, cluster_name)
        start_all_services(ambari, cluster_name)

if __name__ == "__main__":
    main()

