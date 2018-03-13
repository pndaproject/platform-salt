{% set settings = salt['pillar.get']('grafana', {}) -%}

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set pnda_graphite_port = 8013 %}
{% set pnda_graphite_host = salt['pnda.get_hosts_for_role']('graphite')[0] %}

{% set grafana_login = pillar['pnda']['user'] %}
# Because grafana is checking for password length, we need a password of at least 8 characters
# So, we double the password (if the pnda password is 'pnda' then the grafana password will be 'pndapnda'
{% set grafana_pass = pillar['pnda']['password']*2 %}

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
        pnda_user: {{ grafana_login }}
        pnda_password: {{ grafana_pass }}
    - cwd: /
    - require:
      - service: grafana-server_start

{% for ds in datasources %}
grafana-create_datasources_{{ loop.index }}:
  cmd.script:
    - name: salt://grafana/files/scripts/create_or_update_ds.py
    - args: |
        {{ grafana_login }} {{ grafana_pass }} 'http://localhost:3000' '{{ ds }}'
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
        pnda_user: {{ grafana_login }}
        pnda_password: {{ grafana_pass }}
    - cwd: /
    - require:
      - file: grafana-copy_dashboard_{{ dash }}
{% endfor %}
