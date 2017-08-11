# Import python libs
"""
  To monitor pnda service status
"""
from __future__ import absolute_import

import logging

LOGGER = logging.getLogger(__name__)


def beacon(config):# pylint: disable=W0612,W0613
    """
      Beacons let you use the Salt event system to monitor non-Salt processes
    """
    ret_dict = dict()
    ret = list()
    result = __salt__['pnda_service_restart.managehadoopclusterrestart']()# pylint: disable=E0602,E0603

    if result:
        ret_dict['Restarted'] = True
        ret.append(ret_dict)
    else:
        ret_dict['Restarted'] = False
        ret.append(ret_dict)
    return ret
