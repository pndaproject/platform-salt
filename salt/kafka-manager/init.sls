{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set release_directory = salt['pillar.get']('kafkamanager:release_directory', '/srv') %}
{% set release_version = salt['pillar.get']('kafkamanager:release_version', '1.3.0.4') %}
{% set release_filename = 'kafka-manager-' + release_version + '.zip' %}

{%- set zk_servers = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_ips']() -%}
{%-   do zk_servers.append(ip + ':2181') -%}
{%- endfor -%}


kafka-manager-install_unzip:
  pkg.installed:
    - name: unzip

kafka-manager-dl-and-extract:
  archive.extracted:
    - name: {{ release_directory }}
    - source: {{ packages_server }}/platform/releases/kafka-manager/{{ release_filename }}
    - source_hash: {{ packages_server }}/platform/releases/kafka-manager/{{ release_filename }}.sha512.txt
    - archive_format: zip
    - if_missing: {{ release_directory }}/kafka-manager-{{ release_version }}

kafka-manager-create_link:
  file.symlink:
    - name: {{ release_directory }}/kafka-manager
    - target: {{ release_directory }}/kafka-manager-{{ release_version }}

kafka-manager-set-configuration-file:
  file.managed:
    - name: {{ release_directory }}/kafka-manager-{{ release_version }}/conf/application.conf
    - source: salt://kafka-manager/templates/application.conf.tpl
    - template: jinja
    - context:
      application_secret: {{ salt['random.get_str']('128') }}
      zk_servers: {{ zk_servers }}

kafka-manager-install-application_configuration:
  file.managed:
    - name: {{ release_directory }}/kafka-manager-{{ release_version }}/conf/application.ini
    - source: salt://kafka-manager/files/application.ini

kafka-manager-install-kafka-manager-upstart-script:
  file.managed:
    - name: /etc/init/kafka-manager.conf
    - source: salt://kafka-manager/files/kafka-manager.conf

kafka-manager-update-kafka-manager:
  file.managed:
    - name: {{ release_directory }}/kafka-manager-{{ release_version }}/bin/kafka-manager
    - mode: 755

kafka-manager-service:
  service.running:
    - name: kafka-manager
    - enable: true
    - init_delay: 10
    - watch:
      - file: kafka-manager-create_link
      - file: kafka-manager-set-configuration-file
      - file: kafka-manager-install-application_configuration
      - file: kafka-manager-install-kafka-manager-upstart-script
