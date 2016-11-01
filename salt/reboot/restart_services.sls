{% set app_directory_name = '/restart' %}
{% set install_dir = pillar['pnda']['homedir'] + app_directory_name %}

include:
  - reboot.install_restart

restart-start:
  service.running:
    - name: pnda-restart
