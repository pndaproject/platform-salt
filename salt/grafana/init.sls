{% set settings = salt['pillar.get']('grafana', {}) -%}
{% set grafana_bind_port = salt['pillar.get']('grafana:bind_port', '3000') %}
{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set pnda_graphite_port = 8013 %}
{% set pnda_graphite_host = salt['pnda.get_hosts_for_role']('graphite')[0] %}

{% set ldap_server = pillar['security']['ldap_server'] %}
{% if ldap_server %}
{% set ldap_enable = true %}
{% set ldap_base_dn = pillar['security']['ldap_base_dn'] %}
{% else %}
{% set ldap_enable = false %}
{% endif %}
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

{% set haproxy_service = salt['pnda.generate_external_link']('haproxy',':8444') %}
{% set grafana_config_dir = '/etc/grafana' %}

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

grafana-add_config:
  file.managed:
    - source: salt://grafana/templates/grafana.ini.tpl
    - name: {{ grafana_config_dir }}/grafana.ini
    - template: jinja
    - context:
        haproxy_service: {{ haproxy_service }}
        ldap_enable: {{ ldap_enable }}

{% if ldap_enable %}
grafana-ldap_config:
  file.managed:
    - source: salt://grafana/templates/ldap.toml.tpl
    - name: {{ grafana_config_dir }}/ldap.toml
    - template: jinja
    - context:
        ldap_host: "{{ ldap_server }}"
        ldap_search_base_dns: "{{ ldap_base_dn }}"
{% endif %}

grafana-systemd:
  file.managed:
    - name: /usr/lib/systemd/system/grafana-server.service
    - source: salt://grafana/templates/grafana-server.service.tpl
    - mode: 644
    - template: jinja
    - context:
      grafana_bind_port: {{ grafana_bind_port }}
      user: grafana
      group: grafana

grafana-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable grafana-server

grafana-restart:
  cmd.run:
    - name: 'service grafana-server stop || echo already stopped; service grafana-server start'
