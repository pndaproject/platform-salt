{%- from 'kafka/settings.sls' import kafka, config with context %}

{% set flavor_cfg = pillar['pnda_flavor']['states'][sls] %}

{% set pnda_cluster = salt['pnda.cluster_name']() %}

{%- set kafka_zookeepers = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_ips']() -%}
{%- do kafka_zookeepers.append(ip+':2181') -%}
{%- endfor -%}

{% set inter_broker_listener = salt['pillar.get']('kafka:inter_broker_listener', 'REPLICATION') %}
{%- set internal_ip = salt['network.interface_ip'](salt['grains.get']('vlans:internal','eth0')) -%}
{%- set producer_ip = salt['network.interface_ip'](salt['grains.get']('vlans:producer','eth0')) -%}
{%- set client_ip = salt['network.interface_ip'](salt['grains.get']('vlans:interfaces','eth0')) -%}

{%- set internal_port = salt['grains.get']('kafka:producer_port',9092) -%}
{%- set replication_port = salt['grains.get']('kafka:producer_port',9093) -%}
{%- set producer_port = salt['grains.get']('kafka:producer_port',9094) -%}
{%- set client_port = salt['grains.get']('kafka:client_port',9095) -%}

{% set listener_map = salt['pillar.get']('kafka:listener_map', 'PRODUCER:PLAINTEXT,CLIENT:PLAINTEXT,REPLICATION:PLAINTEXT,INTERNAL_PLAINTEXT:PLAINTEXT') %}
{% set listeners = 'listeners=PRODUCER://'+producer_ip+':'+producer_port|string+',CLIENT://'+client_ip+':'+client_port|string+',REPLICATION://'+internal_ip+':'+replication_port|string+',INTERNAL_PLAINTEXT://'+internal_ip+':'+internal_port|string %}
{% set advertised_listeners = 'advertised.listeners=PRODUCER://'+producer_ip+':'+producer_port|string+',CLIENT://'+client_ip+':'+client_port|string+',REPLICATION://'+internal_ip+':'+replication_port|string+',INTERNAL_PLAINTEXT://'+internal_ip+':'+internal_port|string %}

{% set mem_xmx = (((salt['grains.get']('mem_total')/1000)+1)*0.5)|int %}

include:
  - kafka

kafka-directories:
  file.directory:
    - user: kafka
    - group: kafka
    - mode: 755
    - makedirs: True
    - names:
{% for log_dir in config.log_dirs %}
      - {{ log_dir }}
{% endfor %}

kafka-server-conf:
  file.managed:
    - name: {{ kafka.real_home }}/config/server.properties
    - source: salt://kafka/templates/server.properties.tpl
    - user: kafka
    - group: kafka
    - mode: 644
    - template: jinja
    - context:
      zk_hosts: {{ kafka_zookeepers|join(',') }}
      kafka_log_retention_bytes: {{ flavor_cfg.kafka_log_retention_bytes }}
      listener_map: {{ listener_map }}
      listeners: {{ listeners }}
      advertised_listeners: {{ advertised_listeners }}
      inter_broker_listener: {{ inter_broker_listener }}

{% if grains['os'] == 'Ubuntu' %}
kafka-copy_kafka_service:
  file.managed:
    - source: salt://kafka/templates/kafka.init.conf.tpl
    - name: /etc/init/kafka.conf
    - mode: 644
    - template: jinja
    - context:
      workdir: {{ kafka.prefix }}
      mem_xmx: {{ mem_xmx }}
      mem_xms: {{ mem_xmx }}
{% elif grains['os'] == 'RedHat' %}
kafka-copy_script:
  file.managed:
    - source: salt://kafka/templates/kafka-start.sh.tpl
    - name: {{ kafka.prefix }}/kafka-start-script.sh
    - mode: 755
    - template: jinja
    - context:
      workdir: {{ kafka.prefix }}
kafka-copy_env:
  file.managed:
    - source: salt://kafka/templates/kafka-env.tpl
    - name: /etc/default/kafka-env
    - mode: 644
    - template: jinja
    - context:
      mem_xmx: {{ mem_xmx }}
      mem_xms: {{ mem_xmx }}

kafka-copy_kafka_systemd:
  file.managed:
    - source: salt://kafka/templates/kafka.service.tpl
    - name: /usr/lib/systemd/system/kafka.service
    - mode: 644
    - template: jinja
    - context:
      workdir: {{ kafka.prefix }}

kafka-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable kafka
{% endif %}

kafka-logs-configuration-dirs:
  file.directory:
    - name: /var/log/pnda/kafka
    - user: kafka
    - group: kafka
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

kafka-logs-configuration:
  file.replace:
    - name: {{ kafka.real_home }}/config/log4j.properties
    - pattern: '(\${kafka.logs.dir})'
    - repl: '/var/log/pnda/kafka'

kafka-start_service:
  cmd.run:
    - name: 'service kafka stop || echo already stopped; service kafka start'
