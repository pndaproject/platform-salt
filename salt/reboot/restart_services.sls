include:
  - reboot.install_restart

{% if pillar['hadoop.distro'] == 'HDP' %}
{% set hadoop_manager_service = 'ambari-server' %}
{% else %}
{% set hadoop_manager_service = 'cloudera-scm-manager' %}
{% endif %}


restart-start_hadoop_manager:
  cmd.run:
    - name: 'service {{ hadoop_manager_service }} start || echo {{ hadoop_manager_service }} already running'

restart-start_service:
  cmd.run:
    - name: 'service pnda-restart stop || echo already stopped; service pnda-restart start'
