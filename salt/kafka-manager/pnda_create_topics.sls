{% set cluster = salt['pnda.cluster_name']() %}
{% set topic = 'avro.internal.testbot' %}
{% set partitions = '1' %}
{%- set replication = salt['pnda.kafka_brokers_hosts']()|length -%}
{% set km_port = salt['pillar.get']('kafkamanager:bind_port', 10900) %}

kafka-manager_create_topics:
  http.query:
    - name: 'http://localhost:{{ km_port }}/clusters/{{ cluster }}/topics/create'
    - method: 'POST'
    - status: 200
    - text: False
    - backend: 'requests'
    - data:
        topic: "{{ topic }}"
        partitions: "{{ partitions }}"
        replication: "{{ replication }}"