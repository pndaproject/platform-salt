include:
  - reboot.install_restart

restart-start_service:
  cmd.run:
    - name: 'service pnda-restart stop || echo already stopped; service pnda-restart start'
