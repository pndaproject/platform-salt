{% if data['data']['service'] == 'hbase_thrift' %}
reactor-hadoop_service_addon_start:
  local.cmd.run:
    - tgt: {{ data['data']['target'] }}
    - arg:
      - /usr/hdp/current/hbase-master/bin/hbase-daemon.sh start thrift -p 9090 --infoport 9091
{% endif %}
{% if data['data']['service'] == 'hbase_rest' %}
reactor-hadoop_service_addon_start:
  local.cmd.run:
    - tgt: {{ data['data']['target'] }}
    - arg:
      - /usr/hdp/current/hbase-master/bin/hbase-daemon.sh start rest -p 20550 --infoport 20551
{% endif %}
