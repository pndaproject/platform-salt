#!/usr/bin/env python

"""
Name:       cloudera_config
Purpose:    Gathers information about instances that is required to run cm_setup such as
            the ip address and hostname of each one.

Author:     PNDA team

Created:    14/03/2016
"""

import cm_setup

ips = {}
{% for host, ip in ips.items() -%}
ips['{{ host }}'] = '{{ ip[0] }}'
{% endfor %}

roles = {}
{% for host, minion_grains in hadoop_config.items() -%}
roles['{{ host }}'] = '{{ minion_grains['hadoop']['role'] }}'
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

{%- if parcel_repo %}
parcel_repo = "{{ parcel_repo }}"
{%- else %}
parcel_repo = None
{%- endif %}

{%- if parcel_version %}
parcel_version = "{{ parcel_version }}"
{%- else %}
parcel_version = None
{%- endif %}

{% set cm_username = pillar['admin_login']['user'] %}
{% set cm_password = pillar['admin_login']['password'] %}

{% set anaconda_parcel_repo = pillar['anaconda']['parcel_repo'] %}
{% set anaconda_parcel_version = pillar['anaconda']['parcel_version'] %}

if __name__ == '__main__':
    cm_setup.setup_hadoop(manager, nodes,
                          cluster_name='{{ cluster_name }}', cm_username='{{ cm_username }}',
                          cm_password='{{ cm_password }}',
                          parcel_repo=parcel_repo, parcel_version=parcel_version,
                          anaconda_repo='{{ anaconda_parcel_repo }}', anaconda_version='{{ anaconda_parcel_version }}')
