include:
  - reboot.install_restart

restart-start_cloudera_manager:
  cmd.run:
    - name: 'service cloudera-scm-manager start'

restart-start_service:
  cmd.run:
    - name: 'service pnda-restart stop || echo already stopped; service pnda-restart start'
