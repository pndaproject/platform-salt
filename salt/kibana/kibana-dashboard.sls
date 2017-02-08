kibana-dashboard-running:
  service.running:
    - name: kibana

kibana-dashboard-configure:
  cmd.script:
    - source: salt://kibana/files/configure-dashboard.sh
