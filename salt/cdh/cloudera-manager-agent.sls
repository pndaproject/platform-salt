{%- set cm_host = salt['pnda.ip_addresses']('cloudera_manager')[0] -%}

cloudera-manager-agent-install_packages:
  pkg.installed:
    - pkgs:
      - cloudera-manager-daemons
      - cloudera-manager-agent

cloudera-manager-agent-configure_ini:
  cmd.run:
    - name: sed -i -e 's/server_host.*$/server_host={{ cm_host }}/g' /etc/cloudera-scm-agent/config.ini

cloudera-manager-agent-start_service:
  cmd.run:
    - name: 'service cloudera-scm-agent stop || echo already stopped; service cloudera-scm-agent start'