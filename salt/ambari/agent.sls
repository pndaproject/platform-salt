{%- set ambari_server_host = salt['pnda.ip_addresses']('hadoop_manager')[0] -%}

ambari-agent-user:
  user.present:
    - name: ambari
    - groups:
      - root

ambari-agent-pkg:
  pkg.installed:
    - pkgs:
      - {{ pillar['ambari-agent']['package-name'] }}: {{ pillar['ambari-agent']['version'] }}
{% if grains['os'] == 'RedHat' %}
      - {{ pillar['libtirpc-devel']['package-name'] }}: {{ pillar['libtirpc-devel']['version'] }}
{%- endif %}
    - ignore_epoch: True

ambari-agent-properties:
  file.managed:
    - name: /etc/ambari-agent/conf/ambari-agent.ini
    - source: salt://ambari/templates/ambari-agent.ini.tpl
    - template: jinja
    - permission: 0644
    - defaults:
        ambari_server_host: {{ ambari_server_host }}      

ambari-agent-create_log_dir:
  file.directory:
    - name: /var/log/pnda/ambari/
    - makedirs: True

{% if grains['os'] == 'RedHat' %}
ambari-agent-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable ambari-agent
{%- endif %}

ambari-agent-start_service:
  cmd.run:
    - name: 'service ambari-agent stop || echo already stopped; service ambari-agent start'