{%- set ambari_server_host = salt['pnda.ip_addresses']('hadoop_manager')[0] -%}

ambari-agent-user:
  user.present:
    - name: ambari
    - groups:
      - root

{% if grains['os'] == 'RedHat' %}
ambari-agent-libtirpc:
  pkg.installed:
    - name: {{ pillar['libtirpc-devel']['package-name'] }}
    - version: {{ pillar['libtirpc-devel']['version'] }}
    - ignore_epoch: True
{%- endif %}

ambari-agent-pkg:
  pkg.installed:
    - name: {{ pillar['ambari-agent']['package-name'] }}
    - version: {{ pillar['ambari-agent']['version'] }}
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