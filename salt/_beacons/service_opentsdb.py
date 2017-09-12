# Import python libs
"""
  To monitor pnda opentsdb service status
"""
from __future__ import absolute_import

import requests
import logging
import json
import re

logger = logging.getLogger(__name__)


def beacon(config):# pylint: disable=W0612,W0613
    """
      Beacons let you use the Salt event system to monitor non-Salt processes
    """
    ret_dict = dict()
    ret = list()
    if  __salt__['service.status']('opentsdb'):# pylint: disable=E0602,E0603
        ret_dict['tag'] = 'service/opentsdb/status/running'
        return [ret_dict]
    hadoop_distro = __salt__['pillar.get']('hadoop.distro')  # pylint: disable=E0602,E0603
    if hadoop_distro == 'CDH':
        hBaseStatus =  __salt__['pnda.cloudera_get_service_status']('hbase01')# pylint: disable=E0602,E0603
        if re.search("GOOD|CONCERNING",hBaseStatus):
            ret_dict['tag'] = 'service/opentsdb/status/stop/HBaseUp'
            return [ret_dict]
    else:
        hBaseStatus =  __salt__['pnda.ambari_get_service_status']('HBASE')# pylint: disable=E0602,E0603
        if re.search("STARTED",hBaseStatus):
            ret_dict['tag'] = 'service/opentsdb/status/stop/HBaseUp'
            return [ret_dict]

    ret_dict['tag'] = 'service/opentsdb/status/stop/HBaseDown'
    return [ret_dict]

