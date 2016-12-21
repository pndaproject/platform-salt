{% set app_directory_name = '/restart' %}
{% set install_dir = pillar['pnda']['homedir'] + app_directory_name %}

include:
  - cdh.cloudera-api

reboot-copy_app:
  file.managed:
    - name: {{ install_dir }}/pnda_restart.py
    - source: salt://reboot/files/pnda_restart.py
    - makedirs: True

reboot-copy_config:
  file.managed:
    - name: {{ install_dir }}/properties.json
    - source: salt://reboot/templates/properties.json.tpl
    - template: jinja

reboot-copy_upstart:
  file.managed:
    - name: /etc/init/pnda-restart.conf
    - source: salt://reboot/templates/pnda-restart.conf.tpl
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}

