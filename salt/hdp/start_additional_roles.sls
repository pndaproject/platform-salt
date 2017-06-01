{% set hbase_master = salt['pnda.hbase_master_host']() %}

hdp-start_hbase_thrift_server:
  cmd.run:
    - name: if [ "`hostname -s`" = "{{ hbase_master }}" ]; then /usr/hdp/current/hbase-master/bin/hbase-daemon.sh start thrift -p 9090 --infoport 9091; fi

hdp-start_hbase_rest_server:
  cmd.run:
    - name: if [ "`hostname -s`" = "{{ hbase_master }}" ]; then /usr/hdp/current/hbase-master/bin/hbase-daemon.sh start rest -p 20550 --infoport 20551; fi
