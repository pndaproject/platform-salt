'''
Module for to check system reboot
'''

# Import python libs
from __future__ import absolute_import
import requests
import time
import logging

logging.basicConfig(level=logging.DEBUG)
LOGGER = logging.getLogger(__name__)
def stop(name):
    ret = {
        'name': name,
        'changes': {},
        'result': False,
        'comment': '',
        'pchanges': {},
    }
    hadoop_distro = __salt__['grains.get']('hadoop.distro')  # pylint: disable=E0602,E0603
    if hadoop_distro == 'HDP':
        result = ambari_stop_all_services()
    else:
        result= cloudera_stop_all_services()

    ret['result'] = result
    return ret

def start(name):
    ret = {
        'name': name,
        'changes': {},
        'result': False,
        'comment': '',
        'pchanges': {},
    }
    hadoop_distro = __salt__['grains.get']('hadoop.distro')  # pylint: disable=E0602,E0603
    if hadoop_distro == 'HDP':
        result = ambari_start_all_services()
    else:
        result= True
        ret['comment'] = "CDH not implemented"

    ret['result'] = result
    return ret

def cloudera_stop_all_services():
    cm_host = __salt__['pnda.hadoop_manager_ip']()  # pylint: disable=E0602,E0603
    cm_user = __salt__['pnda.hadoop_manager_username']()  # pylint: disable=E0602,E0603
    cm_pass = __salt__['pnda.hadoop_manager_password']()  # pylint: disable=E0602,E0603
    cm_name = __salt__['pnda.cluster_name']()  # pylint: disable=E0602,E0603
    headers = {'X-Requested-By': cm_user}
    auth = (cm_user, cm_pass)
    full_uri = 'http://%s:7180/api/v17/clusters/%s/commands/stop' % (cm_host,cm_name)
    response = requests.post(full_uri, auth=auth, headers=headers)
    if response.status_code != 200:
        return False
    response = response.json()
    cmd_id = response['id']

    full_uri = 'http://%s:7180/api/v17/commands/%s' % (cm_host,cmd_id)
    response = requests.get(full_uri, auth=auth)
    if response.status_code != 200:
        return False
    response = response.json()
    while response['active'] is True and response.get('success',None) is None:
        time.sleep(5)
        response = requests.get(full_uri, auth=auth)
        if response.status_code != 200:
            return False
        response = response.json()
    resultMessage = response.get('resultMessage',None)
    if response.get('success',None) is False:
        LOGGER.error('%s (cmd.success is False)' % resultMessage)
        return False
    elif response.get('success',None) is None:
        LOGGER.error('%s (cmd.success is None)' % resultMessage)
        return false
    elif response.get('success',None) is True:
        LOGGER.info('%s (Cluster stopped succeefully)' % resultMessage)
    return True

def ambari_stop_all_services():
    cluster_name = __salt__['pnda.cluster_name']()  # pylint: disable=E0602,E0603
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

    response = ambari_request('/clusters/%s/services' % (cluster_name), stop_command)
    if response is not None:
        return ambari_wait_on_cmd( response['href'], 'services to be stopped by Ambari')
    return False

def ambari_start_all_services():
    cluster_name = __salt__['pnda.cluster_name']()  # pylint: disable=E0602,E0603
    stop_command = '''{
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

    response = ambari_request('/clusters/%s/services' % (cluster_name), stop_command)
    if response is not None:
        return ambari_wait_on_cmd( response['href'], 'services to be stopped by Ambari')
    return False

def ambari_wait_on_cmd(tracking_uri, msg):
    LOGGER.info('Waiting for %s...', msg)
    progress_percent = 0
    while progress_percent < 100:
        time.sleep(5)
        status_reponse = ambari_request(tracking_uri)
        LOGGER.debug(status_reponse['Requests'])
        cmd_status = status_reponse['Requests']['request_status']
        progress_percent = int(status_reponse['Requests']['progress_percent'])
        LOGGER.info('Progress for %s: %s%% - %s', tracking_uri, progress_percent, cmd_status)
    if cmd_status == 'COMPLETED':
        return True
    return False

def ambari_request(uri,body=None):
    cm_host = __salt__['pnda.hadoop_manager_ip']()  # pylint: disable=E0602,E0603
    cm_user = __salt__['pnda.hadoop_manager_username']()  # pylint: disable=E0602,E0603
    cm_pass = __salt__['pnda.hadoop_manager_password']()  # pylint: disable=E0602,E0603

    headers = {'X-Requested-By': cm_user}
    auth = (cm_user, cm_pass)
    if uri.startswith("http"):
        full_uri = uri
    else:
        full_uri = 'http://%s:8080/api/v1%s' % (cm_host, uri)


    if body is None:
        response = requests.get(full_uri, auth=auth, headers=headers)
    else:
        response = requests.put(full_uri, body, auth=auth, headers=headers)
    LOGGER.debug('Response to command = %s', response.status_code)
    LOGGER.debug(response.text)
    try:
        return response.json()
    except ValueError:
        return None
