"""
Post system reboot status to the console backend
"""
import json
import time
import requests
import logging

# retry the start service only for every DOWN_COUNT_MAX
DOWN_COUNT_MAX = 3
# maximum retry count is RETRY_COUNT_MAX
RETRY_COUNT_MAX = 3
# retry_count will reset after RETRY_COUNT_MAX
RETRY_COUNT_RESET = 10

def ambari_request( uri, body=None):
    hadoop_manager_ip = __salt__['pnda.hadoop_manager_ip']()
    hadoop_manager_username = __salt__['pillar.get']('admin_login:user')
    hadoop_manager_password = __salt__['pillar.get']('admin_login:password')

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
    logging.error(response.text)
    try:
        return response.json()
    except ValueError:
        return None

def wait_on_cmd( tracking_uri, msg):
    logging.info('Waiting for %s %s...', tracking_uri,msg)
    progress_percent = 0
    while progress_percent < 100:
        time.sleep(5)
        status_reponse = ambari_request(tracking_uri)
        logging.debug(status_reponse['Requests'])
        cmd_status = status_reponse['Requests']['request_status']
        progress_percent = int(status_reponse['Requests']['progress_percent'])
        logging.info('Progress for %s: %s%% - %s', tracking_uri, progress_percent, cmd_status)
    return cmd_status
def get_request_status(tracking_uri):
    status_reponse = ambari_request(tracking_uri)
    ret = {
        'changes': {},
        'result': True
    }

    resp = status_reponse['Requests']
    if resp['timed_out_task_count'] or resp['aborted_task_count'] \
        or resp['failed_task_count'] or resp['queued_task_count'] \
        or resp['timed_out_task_count']:
	   ret['result'] = False
    ret['changes']['Requests'] = status_reponse['Requests']
    host_name = []
    role = []
    status = []
    stderr = []
    for task in status_reponse['tasks']:
        task_reponse = ambari_request(task['href'])
        host_name.append(task_reponse['Tasks']['host_name'])
        role.append(task_reponse['Tasks']['role'])
        status.append(task_reponse['Tasks']['status'])
        stderr.append(task_reponse['Tasks']['stderr'])
    ret['changes']['tasks'] = {'host_name': host_name,
                               'role': role,
	                       'status': status,
                               'stderr': stderr}
    return ret


def start_all_services(name):
    """  post kernel reboot status to metric page"""
    ret = {
        'name': name,
        'changes': {},
        'result': False,
        'comment': '',
        'pchanges': {},
    }
    servicelist = __salt__['grains.get']('serviceList')  # pylint: disable=E0602,E0603
    if not servicelist:
       servicelist = {'up_count': 0,'down_count': 0,'retry_count': 0}
    if servicelist['retry_count'] > RETRY_COUNT_MAX:
        ret['result'] = True
        ret['comment'] = "Max retry count {} reached, not starting services".format(RETRY_COUNT_MAX)
        return ret
    if servicelist['down_count'] < DOWN_COUNT_MAX:
        ret['result'] = True
        ret['comment'] = "Max down count {} not reached, so not starting services".format(DOWN_COUNT_MAX)
        return ret

        

    cluster_name = __salt__['pnda.cluster_name']()# pylint: disable=E0602,E0603
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
    response = ambari_request( '/clusters/%s/services' % (cluster_name), start_command)
    if response is not None:
        wait_on_cmd( response['href'], 'services to be started by Ambari')
        status = get_request_status( response['href'])
        ret['result'] = status['result']
        ret['changes'] = status['changes']
    return ret
