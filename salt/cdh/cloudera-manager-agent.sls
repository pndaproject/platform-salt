{%- set cm_host = salt['pnda.ip_addresses']('hadoop_manager')[0] -%}

cloudera-manager-agent-install_daemons:
  pkg.installed:
    - name: {{ pillar['cloudera-manager-daemons']['package-name'] }}
    - version: {{ pillar['cloudera-manager-daemons']['version'] }}
    - ignore_epoch: True

cloudera-manager-agent-install_agent:
  pkg.installed:
    - name: {{ pillar['cloudera-manager-agent']['package-name'] }}
    - version: {{ pillar['cloudera-manager-agent']['version'] }}
    - ignore_epoch: True

cloudera-manager-agent-configure_ini:
  cmd.run:
    - name: sed -i -e 's/server_host.*$/server_host={{ cm_host }}/g' /etc/cloudera-scm-agent/config.ini

cloudera-manager-agent-start_service:
  cmd.run:
    - name: 'service cloudera-scm-agent stop || echo already stopped; service cloudera-scm-agent start'