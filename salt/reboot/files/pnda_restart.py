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
from cm_api.api_client import ApiResource

def connect_cm(cm_api, cm_username, cm_password):
    api = ApiResource(cm_api, version=11, username=cm_username, password=cm_password)
    cloudera_manager = api.get_cloudera_manager()
    return api, cloudera_manager

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

def main():
    print 'PNDA Watchdog starting'
    with open('properties.json', 'r') as props_file:
        config = json.load(props_file)

    logging.basicConfig(format='%(asctime)s %(levelname)s %(message)s',
                        level=logging.getLevelName(config['log_level']),
                        stream=sys.stderr)

    logging.debug('Config loaded')

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

if __name__ == "__main__":
    main()

