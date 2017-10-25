{% set roles = salt['grains.get']('roles', '') %}
reboot-beacon_create_conf_file:
  file.managed:
    - name: /etc/salt/minion.d/beacons.conf
    - contents: 
      - "beacons:"
      - "  kernel_reboot_required:"
      - "    interval: 30"
      - "    disable_during_state_run: True"
{% if 'hadoop_manager' in roles %}
      - "  service_restart:"
      - "    interval: 30"
      - "    disable_during_state_run: True"
{% endif %}
{% if 'opentsdb' in roles %}
      - "  service_opentsdb:"
      - "    interval: 30"
      - "    disable_during_state_run: True"
{% endif %}
