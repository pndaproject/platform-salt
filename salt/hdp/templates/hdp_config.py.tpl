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
roles['{{ host }}'] = '{{ minion_grains['cloudera']['role'] }}'
{% if 'hadoop_manager' in minion_grains.get('roles', []) %}
manager = ips['{{ host }}']
{% endif %}
{% endfor %}

nodes = []
for host in ips.keys():
    nodes.append({'type': roles[host],
        'id': None,
        'private_addr': ips[host],
        'public_addr': ips[host]})

{% set ambari_username = pillar['admin_login']['user'] %}
{% set ambari_password = pillar['admin_login']['password'] %}

{% set anaconda_parcel_repo = pillar['anaconda']['parcel_repo'] %}
{% set anaconda_parcel_version = pillar['anaconda']['parcel_version'] %}

if __name__ == '__main__':
    hdp_setup.setup_hadoop(manager, nodes,
                          cluster_name='{{ cluster_name }}', ambari_username='{{ ambari_username }}',
                          ambari_password='{{ ambari_password }}',
                          hdp_core_stack_repo='{{ hdp_core_stack_repo }}', hdp_utils_stack_repo='{{ hdp_utils_stack_repo }}',
                          anaconda_repo='{{ anaconda_parcel_repo }}', anaconda_version='{{ anaconda_parcel_version }}')
