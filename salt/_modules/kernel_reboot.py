'''
Module for to check system reboot
'''

# Import python libs
from __future__ import absolute_import
from subprocess import Popen


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
