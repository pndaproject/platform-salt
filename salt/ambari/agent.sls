{%- set ambari_server_host = salt['pnda.ip_addresses']('hadoop_manager')[0] -%}

ambari-agent-user:
  user.present:
    - name: ambari
    - groups:
      - root

{% if grains['os'] in ('RedHat', 'CentOS') %}
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
    - mode: 0644
    - defaults:
        ambari_server_host: {{ ambari_server_host }}

ambari-agent-create_log_dir:
  file.directory:
    - name: /var/log/pnda/ambari/
    - makedirs: True

{% if grains['os'] in ('RedHat', 'CentOS') %}
ambari-agent-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable ambari-agent
{%- endif %}

{% if grains['os'] == 'Ubuntu' %}
# See AMBARI-22532, and remove this work around when that is resolved
ambari-agent-patchfix1:
  file.replace:
    - name: /usr/lib/ambari-agent/lib/resource_management/core/providers/package/apt.py
    - pattern: '^.*if repo_id in package\[2\]:'
    - repl: '          if urllib.unquote(repo_id).decode("utf-8") in urllib.unquote(package[2]).decode("utf-8"):'

ambari-agent-patchfix2:
  file.replace:
    - name: /usr/lib/ambari-agent/lib/resource_management/core/providers/package/apt.py
    - pattern: 'import subprocess'
    - repl: |
        import subprocess
        import urllib
{% endif %}

ambari-agent-start_service:
  cmd.run:
    - name: 'service ambari-agent stop || echo already stopped; service ambari-agent start'