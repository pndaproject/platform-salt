{% set logstash_version = salt['pillar.get']('logstash-cluster:version', '5.0.0') %}
{% set logstash_directory = salt['pillar.get']('logstash-cluster:directory', '') %}
{% set logstash_logdir = salt['pillar.get']('logstash-cluster:logdir', '') %}
{% set logstash_confdir = salt['pillar.get']('logstash-cluster:confdir', '') %}
{% set logstash_datadir = salt['pillar.get']('logstash-cluster:datadir', '') %}
{% set logstash_inputdir = salt['pillar.get']('logstash-cluster:inputdir', '') %}


{%- set es_ingest_grains = salt['mine.get']('G@roles:elk-es-ingest', 'grains.items', expr_form='compound') %}

{% set es_ingest_hostnames = [] %}
{% for grains in es_ingest_grains.values() %}
  {% do es_ingest_hostnames.append(grains['fqdn']) %}
{% endfor %}

logstash-logstash:
  group.present:
    - name: logstash
  user.present:
    - name: logstash
    - gid_from_name: True
    - groups:
      - logstash

logstash-create_logstash_dir:
  file.directory:
    - name: {{logstash_directory}}
    - user: root
    - group: root
    - dir_mode: 777
    - makedirs: True

logstash-create_logstash_logdir:
  file.directory:
    - name: {{logstash_logdir}}
    - user: logstash
    - group: logstash
    - dir_mode: 755
    - makedirs: True

logstash-create_logstash_datadir:
  file.directory:
    - name: {{logstash_datadir}}
    - user: logstash
    - group: logstash
    - dir_mode: 755
    - makedirs: True

logstash-create_logstash_inputdir:
  file.directory:
    - name: {{logstash_inputdir}}
    - user: logstash
    - group: logstash
    - dir_mode: 755
    - makedirs: True

logstash-dl_and_extract_logstash:
  archive.extracted:
    - name: {{logstash_directory}}
    - source: https://artifacts.elastic.co/downloads/logstash/logstash-{{ logstash_version }}.tar.gz
    - source_hash: https://artifacts.elastic.co/downloads/logstash/logstash-{{ logstash_version }}.tar.gz.sha1
    - archive_format: tar
    - tar_options: v
    - if_missing: {{logstash_directory}}/logstash-{{ logstash_version }}

logstash-create_logstash_confdir:
  file.directory:
    - name: {{logstash_confdir}}
    - user: logstash
    - group: logstash
    - dir_mode: 755
    - makedirs: True

logstash-copy_configuration_logstash:
  file.managed:
    - source: salt://logstash/files/templates/logstash.conf.tpl
    - user: logstash
    - group: logstash
    - name: {{logstash_confdir}}/logstash.conf
    - template: jinja
    - context:
      list_of_ingest: {{ es_ingest_hostnames }}
      input_dir: {{logstash_inputdir}}/*

/etc/init/logstash.conf:
  file.managed:
    - source: salt://logstash/files/templates/logstash.init.conf.tpl
    - mode: 644
    - template: jinja
    - context:
      installdir: {{logstash_directory}}/logstash-{{ logstash_version }}
      logdir: {{logstash_logdir }}
      confpath: {{logstash_confdir }}/logstash.conf
      datadir: {{logstash_datadir}}

logstash-service:
  service.running:
    - name: logstash
    - enable: true
    - watch:
      - file: /etc/init/logstash.conf

