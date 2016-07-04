{% set zk_servers = salt['zk.zookeeper_quorum']() %}

include:
  - opentsdb

pnda_opentsdb-pnda-opentsdb-configuration:
  file.replace:
    - name: /etc/opentsdb/opentsdb.conf
    - pattern: '.*tsd.storage.hbase.zk_quorum =.*'
    - repl: 'tsd.storage.hbase.zk_quorum = {{ zk_servers }}'

pnda_opentsdb-pnda-opentsdb-configuration-lastvalue:
  file.replace:
    - name: /etc/opentsdb/opentsdb.conf
    - append_if_not_found: True
    - pattern: '.*tsd.core.meta.enable_realtime_ts =.*'
    - repl: 'tsd.core.meta.enable_realtime_ts = true'

pnda_opentsdb-pnda-opentsdb-configuration-cors:
  file.replace:
    - name: /etc/opentsdb/opentsdb.conf
    - append_if_not_found: True
    - pattern: '.*tsd.http.request.cors_domains =.*'
    - repl: 'tsd.http.request.cors_domains = *'
    
pnda_opentsdb-update-opentsdb-default-file:
  file.managed:
    - name: /etc/default/opentsdb
    - contents: JAVA_HOME=/usr/lib/jvm/java-8-oracle
