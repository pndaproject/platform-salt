include:
  - reboot.install_restart

restart-start:
  service.running:
    - name: pnda-restart
