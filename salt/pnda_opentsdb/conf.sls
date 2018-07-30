
{% set hadoop_zk = [] %}
{% for ip in salt['pnda.get_hosts_by_hadoop_role']('zookeeper_server') %}
{% do hadoop_zk.append(ip+':2181') %}
{% endfor %}

include:
  - opentsdb

pnda_opentsdb-pnda-opentsdb-cmd_perms:
  file.managed:
    - name: /usr/share/opentsdb/bin/tsdb
    - mode: 755
    - replace: False

pnda_opentsdb-pnda-opentsdb-configuration:
  file.replace:
    - name: /etc/opentsdb/opentsdb.conf
    - pattern: '.*tsd.storage.hbase.zk_quorum =.*'
    - repl: 'tsd.storage.hbase.zk_quorum = {{ hadoop_zk | join(',') }}'

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

pnda_opentsdb-pnda-opentsdb-configuration-ui:
  file.replace:
    - name: /etc/opentsdb/opentsdb.conf
    - append_if_not_found: True
    - pattern: '.*tsd.core.enable_ui =.*'
    - repl: 'tsd.core.enable_ui = false'

{% if grains['hadoop.distro'] == 'HDP' %}
pnda_opentsdb-pnda-opentsdb-hbase-zk-root:
  file.replace:
    - name: /etc/opentsdb/opentsdb.conf
    - append_if_not_found: True
    - pattern: '.*tsd.storage.hbase.zk_basedir =.*'
    - repl: 'tsd.storage.hbase.zk_basedir = /hbase-unsecure'
{% endif %}

