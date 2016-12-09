{{ env }}:

  '*':
    - tasks.system_update
    - motd
    - pnda.user
    - hostsfile
    - java
    - java.env
    - ntp
    - logserver.logshipper

  'roles:zookeeper':
    - match: grain
    - zookeeper

  'roles:kafka':
    - match: grain
    - kafka.server

  'roles:kafka_manager':
    - match: grain
    - kafka-manager

  'roles:platform_testing_general':
    - match: grain
    - jmxproxy
    - platform-testing.general

  'roles:elk':
    - match: grain
    - curator
    - elasticsearch
    - kibana

  'roles:logserver':
    - match: grain
    - logserver.logserver

  'roles:kibana_dashboard':
    - match: grain
    - kibana.kibana-dashboard

  'roles:console_frontend':
    - match: grain
    - nginx
    - console-frontend

  'roles:console_backend_data_logger':
    - match: grain
    - console-backend.data-logger
    - console-backend.data-manager

  'roles:console_backend_data_manager':
    - match: grain
    - console-backend.data-manager

  'roles:graphite':
    - match: grain
    - graphite

  'roles:grafana':
    - match: grain
    - grafana

  'roles:opentsdb':
    - match: grain
    - snappy

  'cloudera:*':
    - match: grain
    - cdh.create_data_dirs
    - snappy

  'roles:mysql_connector':
    - match: grain
    - mysql.connector
    
  'roles:oozie_database':
    - match: grain
    - cdh.oozie_mysql

  'roles:cloudera_manager':
    - match: grain
    - cdh.cloudera-keys
    - cdh.cloudera-manager

  'roles:platform_testing_cdh':
    - match: grain
    - platform-testing.cdh

  'roles:package_repository':
    - match: grain
    - package-repository

  'roles:pnda_restart':
    - match: grain
    - reboot.install_restart

  'roles:elk-es-*':
   - match: grain
   - elasticsearch-cluster

  'roles:elk-logstash':
   - match: grain
   - logstash

