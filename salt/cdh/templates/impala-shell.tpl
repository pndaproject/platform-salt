#!/usr/bin/env python
{% set cm_ip = salt['pnda.ip_addresses']('cloudera_manager')[0] %}
{% set cm_username = pillar['admin_login']['user'] %}
{% set cm_password = pillar['admin_login']['password'] %}
import sys
import pexpect
from cm_api.api_client import ApiResource

api = ApiResource('{{ cm_ip }}', version=6, username='{{ cm_username }}', password='{{ cm_password }}')
cluster = api.get_cluster(api.get_all_clusters()[0].name)

for service in cluster.get_all_services():
    if service.type == "IMPALA":
        for role in service.get_all_roles():
            if role.type == "IMPALAD":
                impala_host = api.get_host(role.hostRef.hostId).hostname
                print '%s - %s' % (impala_host, role.healthSummary)
                if role.healthSummary in ['GOOD', 'CONCERNING'] and role.roleState == 'STARTED':
                    process = pexpect.spawn('/opt/cloudera/parcels/CDH/bin/impala-shell -i ' + impala_host)
                    process.interact()
                    sys.exit(0)

print "Did not find a healthy impala daemon"
sys.exit(1)
