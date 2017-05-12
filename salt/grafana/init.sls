{% set settings = salt['pillar.get']('grafana', {}) -%}

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set pnda_graphite_port = 8013 %}
{% set pnda_graphite_host = salt['pnda.ip_addresses']('graphite')[0] %}
{% set datasources = [
    '{ "name": "PNDA OpenTSDB", "type": "opentsdb", "url": "http://localhost:4242", "access": "proxy", "basicAuth": false, "isDefault": true }',
    '{{ "name": "PNDA Graphite", "type": "graphite", "url": "http://{}:{}", "access": "proxy", "basicAuth": false, "isDefault": false }}'.format(pnda_graphite_host, pnda_graphite_port) ] %}
{% set dashboard_list = ['PNDA Deployment Manager.json',
                         'PNDA Hadoop.json',
                         'PNDA Kafka Brokers.json',
                         'PNDA.json'] %}


grafana-server_pkg:
  pkg.installed:
    - sources:
      - grafana: {{ mirror_location + settings['package-source'] }}

{% if grains['os'] == 'RedHat' %}
grafana-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable grafana-server
{%- endif %}

grafana-server_start:
  cmd.run:
    - name: 'service grafana-server stop || echo already stopped; service grafana-server start'

grafana-login_script_run:
  cmd.script:
    - name: salt://grafana/templates/grafana-user-setup.sh.tpl
    - template: jinja
    - context:
        pnda_user: {{ pillar['pnda']['user'] }}
        pnda_password: {{ pillar['pnda']['password'] }}
    - cwd: /
    - require:
      - cmd: grafana-server_start

{% for ds in datasources %}
grafana-create_datasources_{{ loop.index }}:
  cmd.script:
    - name: salt://grafana/files/scripts/create_or_update_ds.py
    - args: |
        {{ pillar['pnda']['user'] }} {{ pillar['pnda']['password'] }} 'http://localhost:3000' '{{ ds }}'
    - shell: /bin/bash
    - cwd: /
    - require:
      - cmd: grafana-login_script_run
{% endfor %}

{% for dash in dashboard_list %}
grafana-copy_dashboard_{{ dash }}:
  file.managed:
    - source: salt://grafana/files/dashboards/{{ dash }}
    - name: /tmp/{{ dash }}.salt.tmp
    - require:
{% for ds in datasources %}
      - cmd: grafana-create_datasources_{{ loop.index }}
{% endfor %}

grafana-import_dashboard-{{ dash }}:
  cmd.script:
    - name: salt://grafana/templates/grafana-import-dashboards.sh.tpl
    - args: "'/tmp/{{ dash }}.salt.tmp'"
    - template: jinja
    - context:
        pnda_user: {{ pillar['pnda']['user'] }}
        pnda_password: {{ pillar['pnda']['password'] }}
    - cwd: /
    - require:
      - file: grafana-copy_dashboard_{{ dash }}
{% endfor %}
