{% set settings = salt['pillar.get']('grafana', {}) -%}
{% set grafana_version = settings.get('version', '3.1.1-1470047149') %}
{% set grafana_hash = settings.get('release_hash', 'sha256=4d3153966afed9b874a6fa6182914d9bd2e69698bbc7c13248d1b7ef09d3d328') %}

{% set grafana_deb_package = 'grafana_' + grafana_version + '_amd64.deb' %}
{% set grafana_deb_location = 'https://grafanarel.s3.amazonaws.com/builds/' + grafana_deb_package %}

{% set pnda_graphite_port = 8013 %}
{% set pnda_graphite_host = salt['pnda.ip_addresses']('graphite')[0] %}

{% set dashboard_list = ['PNDA Deployment Manager.json',
                         'PNDA Hadoop.json',
                         'PNDA Kafka Brokers.json',
                         'PNDA.json'] %}

grafana-server_pkg:
  pkg.installed:
    - sources:
      - grafana: {{ grafana_deb_location }}

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

grafana-create_datasources_run_script:
  cmd.script:
    - name: salt://grafana/templates/grafana-datasources-setup.sh.tpl
    - template: jinja
    - context:
        pnda_user: {{ pillar['pnda']['user'] }}
        pnda_password: {{ pillar['pnda']['password'] }}
        pnda_graphite_host: {{ pnda_graphite_host  }}
        pnda_graphite_port: {{ pnda_graphite_port }}
    - cwd: /
    - require:
      - cmd: grafana-login_script_run

{% for dash in dashboard_list %}
grafana-copy_dashboard_{{ dash }}:
  file.managed:
    - source: salt://grafana/files/dashboards/{{ dash }}
    - name: /tmp/{{ dash }}.salt.tmp
    - require:
      - cmd: grafana-create_datasources_run_script

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
