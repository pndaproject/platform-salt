#!/usr/bin/env python

"""
Name:       hdp_config
Purpose:    Gathers information about instances that is required to run hdp_setup such as
            the ip address and hostname of each one.

Author:     PNDA team

Created:    15/05/2017
"""

import hdp_setup

ips = {}
{% for host, ip in ips.items() -%}
ips['{{ host }}'] = '{{ ip[0] }}'
{% endfor %}

roles = {}
{% for host, minion_grains in hdp_config.items() -%}
roles['{{ host }}'] = '{{ minion_grains['hadoop']['role'] }}'
{% if 'hadoop_manager' in minion_grains.get('roles', []) %}
manager = ips['{{ host }}']
{% endif %}
{% endfor %}

{% set ambari_username = pillar['admin_login']['user'] %}
{% set ambari_password = pillar['admin_login']['password'] %}
{% set domain_name = '.' + pillar['consul']['node'] + '.' + pillar['consul']['data_center'] + '.' + pillar['consul']['domain'] %}

nodes = []
for host in ips.keys():
    nodes.append({'type': roles[host], 'ip_addr': ips[host], 'host_name': '%s%s' % (host,'{{ domain_name }}')})

if __name__ == '__main__':
    hdp_setup.setup_hadoop(manager, nodes,
                          cluster_name='{{ cluster_name }}',
                          domain_name='{{ domain_name }}',
                          ambari_username='{{ ambari_username }}',
                          ambari_password='{{ ambari_password }}',
                          hdp_core_stack_repo='{{ hdp_core_stack_repo }}', hdp_utils_stack_repo='{{ hdp_utils_stack_repo }}')
