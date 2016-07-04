{{ env }}:

  '*':
    - tasks.system_update
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

  'roles:tools':
    - match: grain
    - kafka-manager
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
    - elasticsearch
    - curator
    - kibana
    - kibana.kibana-dashboard

  'roles:console_frontend':
    - match: grain
    - nginx
    - console-frontend

  'roles:console_backend':
    - match: grain
    - console-backend.data-logger
    - console-backend.data-manager

  'roles:grafana':
    - match: grain
    - grafana

  'roles:opentsdb':
    - match: grain
    - pnda_opentsdb.install

  'G@roles:cloudera_* or G@roles:opentsdb':
    - match: compound
    - snappy

  'roles:cloudera_*':
    - match: grain
    - cdh.create_data_dirs

  'roles:cloudera_manager':
    - match: grain
    - cdh.cloudera-keys
    - cdh.cloudera-manager
    - platform-testing.cdh

  'roles:cloudera_management':
    - match: grain
    - mysql.connector
    
  'roles:cloudera_oozie_database':
    - match: grain
    - cdh.oozie_mysql

