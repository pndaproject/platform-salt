'''
Module for to check system reboot
'''

# Import python libs
from __future__ import absolute_import
from subprocess import Popen
import json
import time
import requests

TIMESTAMP_MILLIS = lambda: int(time.time() * 1000)


def reboot():
    """Issue a system reboot command (after a minute) , and retrun control to salt master """
    if not required():
        __salt__['cmd.run']("service salt-minion restart")
        return "Kernel reboot not required"
    cmd_str = 'shutdown -r +1 "Server is going down for kernel upgrade"'
    Popen([cmd_str], shell=True, stdin=None,
          stdout=None, stderr=None, close_fds=True)
    return cmd_str


def required():
    """ returns system needs reboot required or not """
    kernel = __salt__['grains.item']('os')  # pylint: disable=E0602,E0603

    if kernel['os'] == "CentOS" or kernel['os'] == "RedHat":
        try:
            current_version = __salt__['cmd.run']('uname -r')  # pylint: disable=E0602,E0603
            latest_version = __salt__['cmd.run']('rpm -q --last kernel')  # pylint: disable=E0602,E0603
            latest_version = latest_version.split(" ")
            latest_version = [
                version for version in latest_version if 'kernel' in version]
            latest_version = str(latest_version[0]).strip('kernel-')  # pylint: disable=E1310
            if current_version == latest_version:
                return False
        except:  # pylint: disable=W0702
            return False
        return True

    return __salt__['file.file_exists']('/var/run/reboot-required')  # pylint: disable=E0602,E0603

def entry():
    file_exist = required()
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
        comment = "{} updated sucessfully".format(metric)
        return True
    else:
        comment = "{} updated Failed {}".format(
            metric, response.status_code)
        return False
