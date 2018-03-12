{% set p  = salt['pillar.get']('kafka', {}) %}
{%- set prefix  = p.get('prefix', '/opt/pnda/kafka') %}

{%- set kafka_zookeepers = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_hosts']() -%}
{%- do kafka_zookeepers.append(ip+':2181') -%}
{%- endfor -%}

{% set topic = 'avro.internal.testbot' %}
{% set partitions = '1' %}
{%- set replication = salt['pnda.kafka_brokers_hosts']()|length -%}

platform-testing-topic-check-script:
  file.managed:
    - name: {{ prefix }}/topic-check.sh
    - source: salt://platform-testing/files/topic-check.sh
    - mode: 755

platform-testing-create-topic:
  cmd.run:
    - name: {{ prefix }}/bin/kafka-topics.sh --zookeeper {{ kafka_zookeepers|join(',') }} --create --topic {{ topic }} --partitions {{ partitions }} --replication-factor {{ replication }}
    - unless:
      - {{ prefix }}/topic-check.sh {{ prefix }} {{ kafka_zookeepers|join(',') }} {{ topic }}

