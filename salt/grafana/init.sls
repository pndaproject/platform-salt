{% set settings = salt['pillar.get']('grafana', {}) -%}
{% set grafana_version = settings.get('version', '3.1.1-1470047149') %}
{% set grafana_hash = settings.get('release_hash', 'sha256=4d3153966afed9b874a6fa6182914d9bd2e69698bbc7c13248d1b7ef09d3d328') %}
{% set grafana_rpm_hash = settings.get('release_hash', 'sha256=5989ad695554c5bc924c2284bc035feb379e1e8c') %}

{% set extra_mirror = salt['pillar.get']('extra:mirror', 'https://grafanarel.s3.amazonaws.com/builds/') %}

{% set grafana_deb_package = 'grafana_' + grafana_version + '_amd64.deb' %}
{% set grafana_rpm_package = 'grafana_' + grafana_version + '.x86_64.rpm' %}
{% set grafana_deb_location = extra_mirror + grafana_deb_package %}
{% set grafana_rpm_location = extra_mirror + grafana_rpm_package %}
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
{% if grains['os'] == 'Ubuntu' %}
      - grafana: {{ grafana_deb_location }}
{% elif grains['os'] == 'RedHat' %}
      - grafana: {{ grafana_rpm_location }}
{% endif %}

grafana-server_start:
  service.running:
    - name: grafana-server
    - enable: True
    - watch:
      - pkg: grafana-server_pkg

grafana-login_script_run:
  cmd.script:
    - name: salt://grafana/templates/grafana-user-setup.sh.tpl
    - template: jinja
    - context:
        pnda_user: {{ pillar['pnda']['user'] }}
        pnda_password: {{ pillar['pnda']['password'] }}
    - cwd: /
    - require:
      - service: grafana-server_start

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
