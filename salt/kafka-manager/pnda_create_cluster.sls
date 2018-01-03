{% set cluster = salt['pnda.cluster_name']() %}
{% set kafka_version = salt['pillar.get']('kafkamanager:kafka_version', '0.11.0.0') %}
{% set jmx_enabled = 'true' %}
{% set km_port = salt['pillar.get']('kafkamanager:bind_port', 10900) %}

{%- set zk_servers = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_ips']() -%}
{%-   do zk_servers.append(ip + ':2181') -%}
{%- endfor -%}

pnda-create-cluster-start_service:
  cmd.run:
    - name: 'service kafka-manager start && sleep 10 || echo already started;'

pnda-create-cluster-create_cluster:
  http.query:
    - name: 'http://localhost:{{ km_port }}/clusters'
    - method: 'POST'
    - status: 200
    - text: False
    - backend: 'requests'
    - data:
        name: "{{ cluster }}"
        zkHosts: "{{ zk_servers|join(",") }}"
        kafkaVersion: "{{ kafka_version }}"
        jmxEnabled: "{{ jmx_enabled }}"
        jmxUser: ""
        jmxPass: ""
        activeOffsetCacheEnabled: "true"
        securityProtocol: "PLAINTEXT"
    - require:
      - cmd: pnda-create-cluster-start_service
