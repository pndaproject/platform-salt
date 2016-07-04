{% set cluster = salt['pnda.cluster_name']() %}
{% set topic = 'avro.internal.testbot' %}
{% set partitions = '1' %}
{%- set replication = salt['pnda.kafka_brokers_ips']()|length -%}

kafka-manager_create_topics:
  http.query:
    - name: 'http://localhost:9000/clusters/{{ cluster }}/topics/create'
    - method: 'POST'
    - status: 200
    - text: False
    - backend: 'requests'
    - data:
        topic: "{{ topic }}"
        partitions: "{{ partitions }}"
        replication: "{{ replication }}"