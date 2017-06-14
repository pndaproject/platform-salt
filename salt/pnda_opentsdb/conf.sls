
{% if pillar['hadoop.distro'] == 'CDH' %}
{% set zk_service = 'zk01' %}
{% set zk_role = 'SERVER' %}
{% else %}
{% set zk_service = 'ZOOKEEPER' %}
{% set zk_role = 'ZOOKEEPER_SERVER' %}
{% endif %}

{% set hadoop_zk = [] %}
{% for ip in salt['pnda.get_hosts_by_role'](zk_service, zk_role) %}
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

{% if pillar['hadoop.distro'] == 'HDP' %}
pnda_opentsdb-pnda-opentsdb-hbase-zk-root:
  file.replace:
    - name: /etc/opentsdb/opentsdb.conf
    - append_if_not_found: True
    - pattern: '.*tsd.storage.hbase.zk_basedir =.*'
    - repl: 'tsd.storage.hbase.zk_basedir = /hbase-unsecure'
{% endif %}

pnda_opentsdb-update-opentsdb-default-file:
  file.managed:
    - name: /etc/default/opentsdb
    - contents: JAVA_HOME=/usr/lib/jvm/java-8-oracle
