"""
Post system reboot status to the console backend
"""
import json
import time
import requests

TIMESTAMP_MILLIS = lambda: int(time.time() * 1000)

def required(name, file_exist=False):
    """  post kernel reboot status to metric page"""
    ret = {
        'name': name,
        'changes': {},
        'result': False,
        'comment': '',
        'pchanges': {},
    }

    file_exist = __salt__['pillar.get']('file_exist')# pylint: disable=E0602,E0603
    backend_app_port = __salt__['pillar.get'](# pylint: disable=E0602,E0603
        'console_backend_data_logger:bind_port')
    host_ip = __salt__['pnda.ip_addresses'](# pylint: disable=E0602,E0603
        'console_backend_data_logger')[0]
    fqdn = __salt__['grains.item']('id')['id']# pylint: disable=E0602,E0603
    if not backend_app_port:
        backend_app_port = 3001
    if file_exist:
        causes = "System reboot required dut to package or kernel update!"
    else:
        causes = ""

    metric = "node.{0}.reboot_required".format(fqdn)
    data = {
        "data": [
            {
                "source": "node_reboot",
                "metric": metric,
                "causes": causes,
                "value": file_exist,
                "timestamp": TIMESTAMP_MILLIS()
            }
        ],
        "timestamp": TIMESTAMP_MILLIS()
    }
    url = 'http://{0}:{1}/metrics'.format(host_ip, backend_app_port)
    headers = {'Content-Type': 'application/json', 'Connection': 'close'}

    response = requests.post(url, data=json.dumps(data), headers=headers)
    if response.status_code == 200:
        ret['result'] = True
        ret['comment'] = "{} updated sucessfully".format(metric)
    else:
        ret['comment'] = "{} updated Failed {}".format(
            metric, response.status_code)
    return ret
