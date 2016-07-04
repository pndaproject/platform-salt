{% set settings = salt['pillar.get']('grafana', {}) -%}
{% set grafana_version = settings.get('version', '2.1.3') %}
{% set grafana_hash = settings.get('release_hash', 'sha256=7142e7239de5357e3769a286cd3b0c2c63a36234d30516ba9b96e7d088ece5bc') %}

{% set grafana_deb_package = 'grafana_' + grafana_version + '_amd64.deb' %}
{% set grafana_deb_location = 'https://grafanarel.s3.amazonaws.com/builds/' + grafana_deb_package %}

grafana-download-grafana-package:
  file.managed:
    - name: /tmp/{{ grafana_deb_package }}
    - source: {{ grafana_deb_location }}
    - source_hash: {{ grafana_hash }}

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

grafana-login_script_copy:
  file.managed:
    - name: /tmp/grafana-user-setup.sh
    - source: salt://grafana/templates/grafana-user-setup.sh.tpl
    - mode: 755
    - template: jinja

grafana-login_script_run:
  cmd.script:
    - name: grafana-user-setup
    - source: /tmp/grafana-user-setup.sh
    - cwd: /