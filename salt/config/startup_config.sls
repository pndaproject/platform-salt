{% set roles = salt['grains.get']('roles', '') %}

{% if 'hadoop_manager' in roles %}
config-startup_config:
  file.managed:
    - name: /etc/salt/minion.d/startup-config.conf
    - contents: 
      - "startup_states: sls"
      - "sls_list:"
      - "  - platform-testing.platform_bleckbox_testing"
{% endif %}
