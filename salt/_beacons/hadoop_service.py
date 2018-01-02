"""
  To monitor pnda service status
"""
from __future__ import absolute_import

import logging
# retry the start service only for every DOWN_COUNT_MAX
DOWN_COUNT_MAX = 2
# maximum retry count is RETRY_COUNT_MAX
RETRY_COUNT_MAX = 15
# retry_count will reset after RETRY_COUNT_MAX
RETRY_COUNT_RESET = 10


def beacon(config):# pylint: disable=W0612,W0613
    """
      Beacons let you use the Salt event system to monitor non-Salt processes
    """
    logging.debug("enter beacon")
    hadoop_distro = __salt__['pnda.hadoop_distro']()# pylint: disable=E0602,E0603
    cluster_name = __salt__['pnda.cluster_name']()# pylint: disable=E0602,E0603
    ret_dict = dict()
    ret = list()
    if hadoop_distro == 'CDH' :
      result = __salt__['hadoop_service.managehadoopclusterrestart']()# pylint: disable=E0602,E0603
      if result:
        ret_dict['tag'] = 'service/hadoop/status/restarted'
      else:
        ret_dict['tag'] = 'service/hadoop/status/failed'
        ret.append(ret_dict)
      return ret

    #HDP Config
    servicelist = __salt__['grains.get']('serviceList')  # pylint: disable=E0602,E0603
    if not servicelist:
       servicelist = {'up_count': 0,'down_count': 0,'retry_count': 0}

    health_report =__salt__['pnda.ambari_get_cluster_health_report']()# pylint: disable=E0602,E0603
    if (health_report['Host/host_status/HEALTHY']  !=
        health_report['Host/host_state/HEALTHY']):
        servicelist['up_count'] = 0
        servicelist['down_count'] += 1
        if servicelist['retry_count'] > RETRY_COUNT_MAX:
            ret_dict['tag'] = 'service/hadoop/status/maxRetryreached'
        elif servicelist['down_count'] < DOWN_COUNT_MAX:
            ret_dict['tag'] = 'service/hadoop/status/downcount'
        else:
            ret_dict['tag'] = 'service/hadoop/status/stopped'
            servicelist['retry_count'] += 1
            servicelist['down_count'] = 0
    else :
        ret_dict['tag'] = 'service/hadoop/status/running'
        servicelist['up_count'] += 1
        if servicelist['up_count'] > RETRY_COUNT_RESET:
           servicelist['retry_count'] = 0
    ret.append(ret_dict)
    logging.debug(servicelist)

    __salt__['grains.set']("serviceList", {}, True)  # pylint: disable=E0602,E0603
    __salt__['grains.set'](  # pylint: disable=E0602,E0603
        "serviceList", servicelist, True)
    return ret
