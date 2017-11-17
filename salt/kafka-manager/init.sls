{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set release_directory = salt['pillar.get']('kafkamanager:release_directory', '/srv') %}
{% set release_version = salt['pillar.get']('kafkamanager:release_version', '1.3.3.6') %}
{% set release_filename = 'kafka-manager-' + release_version + '.zip' %}
{% set km_port = salt['pillar.get']('kafkamanager:bind_port', 10900) %}

{%- set zk_servers = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_ips']() -%}
{%-   do zk_servers.append(ip + ':2181') -%}
{%- endfor -%}


kafka-manager-install_unzip:
  pkg.installed:
    - name: {{ pillar['unzip']['package-name'] }}
    - version: {{ pillar['unzip']['version'] }}
    - ignore_epoch: True

kafka-manager-dl-and-extract:
  archive.extracted:
    - name: {{ release_directory }}
    - source: {{ packages_server }}/{{ release_filename }}
    - source_hash: {{ packages_server }}/{{ release_filename }}.sha512.txt
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

kafka-manager-install-kafka-manager-service-script:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/init/kafka-manager.conf
    - source: salt://kafka-manager/templates/kafka-manager.conf.tpl
{% elif grains['os'] in ('RedHat', 'CentOS') %}
    - name: /usr/lib/systemd/system/kafka-manager.service
    - source: salt://kafka-manager/templates/kafka-manager.service.tpl
{% endif %}
    - template: jinja
    - context:
      kafka_manager_port: {{ km_port }}

kafka-manager-update-kafka-manager:
  file.managed:
    - name: {{ release_directory }}/kafka-manager-{{ release_version }}/bin/kafka-manager
    - mode: 755

{% if grains['os'] in ('RedHat', 'CentOS') %}
kafka-manager-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable kafka-manager
{%- endif %}

kafka-manager-start_service:
  cmd.run:
    - name: 'service kafka-manager stop || echo already stopped; service kafka-manager start'
