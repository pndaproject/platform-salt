{% set roles = salt['grains.get']('roles', '') %}
{% set role = salt['grains.get']('hadoop:role', '') %}
config-beacon_create_conf_file:
  file.managed:
    - name: /etc/salt/minion.d/beacons.conf
    - contents: 
      - "beacons:"
      - "  kernel_reboot:"
      - "    interval: 30"
      - "    disable_during_state_run: True"
{% if 'hadoop_manager' in roles %}
      - '  hadoop_service:'
      - '    interval: 30'
      - '    disable_during_state_run: True'
{% endif %}
{% if grains['hadoop.distro'] == 'HDP' %}
{% if 'MGR01' in role or 'opentsdb' in roles %}
      - "  service:"
      - "    interval: 30"
      - "    disable_during_state_run: True"
{% if 'opentsdb' in roles %}
      - "    opentsdb:"
{% endif %}
{% if 'MGR01' in role %}
      - "    hbase-thrift:"
      - "    hbase-rest:"
{% endif %}
{% endif %}
{% else %}
{% if 'opentsdb' in roles %}
      - "  service:"
      - "    interval: 30"
      - "    disable_during_state_run: True"
      - "    opentsdb:"
{% endif %}
{% endif %}
