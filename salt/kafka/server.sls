{%- from 'kafka/settings.sls' import kafka, config with context %}

{% set pnda_cluster = salt['pnda.cluster_name']() %}

{%- set kafka_zookeepers = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_ips']() -%}
{%- do kafka_zookeepers.append(ip+':2181') -%}
{%- endfor -%}

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

{% if grains['os'] == 'Ubuntu' %}
kafka-copy_kafka_upstart:
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
    - name: /bin/systemctl daemon-reload
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

kafka-service:
  service.running:
    - name: kafka
    - enable: true
    - watch:
      - file: kafka-server-conf
{% if grains['os'] == 'Ubuntu' %}
      - file: kafka-copy_kafka_upstart
{% elif grains['os'] == 'RedHat' %}
      - file: kafka-copy_kafka_systemd
{% endif %}
