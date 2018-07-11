{% set cluster = salt['pnda.cluster_name']() %}
{% set topic = 'avro.internal.testbot' %}
{% set partitions = '1' %}
{%- set replication = salt['pnda.kafka_brokers_hosts']()|length -%}
{% set km_port = salt['pillar.get']('kafkamanager:bind_port', 10900) %}

{% set context_path = salt['pnda.get_gateway_context_path']('kafka-manager') %}

kafka-manager_create_topics:
  http.query:
    - name: 'http://localhost:{{ km_port }}{{ context_path }}/clusters/{{ cluster }}/topics/create'
    - method: 'POST'
    - status: 200
    - text: False
    - backend: 'requests'
    - data:
        topic: "{{ topic }}"
        partitions: "{{ partitions }}"
        replication: "{{ replication }}"