'''
Watch for system needs reboot 
'''
from __future__ import absolute_import

import logging

log = logging.getLogger(__name__)

def beacon(config):
    ret_dict = dict()
    ret = list()
    result =  __salt__['kernel_reboot.entry'] ()
    result =  __salt__['kernel_reboot.required'] ()
    log.debug("System reboot status from beacon : {0}".format(result))

    if result:
        ret_dict['file_exist']=True
        ret_dict['tag'] = 'Yes' + '/reboot-required'
        ret.append(ret_dict)
    else:
        ret_dict['file_exist']=False
        ret_dict['tag'] = 'No' + '/reboot-required'
        ret.append(ret_dict)
    log.debug("System reboot return dictionary from beacon : {0}".format(ret))
    return ret

