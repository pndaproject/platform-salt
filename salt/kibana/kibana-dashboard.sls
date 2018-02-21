{% set kibana_version = pillar['kibana']['version'] %}
{% set kibana_directory = salt['pillar.get']('kibana:directory', '/opt/pnda') + '/kibana-' + kibana_version %}

kibana-dashboard-running:
  service.running:
    - name: kibana

kibana-dashboard_stage:
  file.managed:
    - name: {{ kibana_directory }}/dashboard.json
    - source: salt://kibana/files/dashboard.json
    - user: kibana
    - group: kibana

kibana-dashboard-import:
  cmd.script:
    - source: salt://kibana/files/import-dashboard.sh
    - cwd: {{ kibana_directory }}
