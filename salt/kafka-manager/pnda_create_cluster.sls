{% set cluster = salt['pnda.cluster_name']() %}
{% set kafka_version = '0.9.0.1' %}
{% set jmx_enabled = 'true' %}

{%- set zk_servers = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_ips']() -%}
{%-   do zk_servers.append(ip + ':2181') -%}
{%- endfor -%}

kafka-manager_restart-service:
  service.running:
    - name: kafka-manager
    - enable: True
    - reload: True

kafka-manager_create_cluster:
  http.query:
    - name: 'http://localhost:9000/clusters'
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
    - require:
      - service: kafka-manager_restart-service
