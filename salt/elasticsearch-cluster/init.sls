{% set elasticsearch_version = salt['pillar.get']('elasticsearch:version', '') %}
{% set cluster_name = salt['pillar.get']('elasticsearch:name', '') %}
{% set elasticsearch_directory = salt['pillar.get']('elasticsearch:directory', '') %}
{% set elasticsearch_datadir = salt['pillar.get']('elasticsearch:datadir', '') %}
{% set elasticsearch_logdir = salt['pillar.get']('elasticsearch:logdir', '') %}
{% set elasticsearch_confdir = salt['pillar.get']('elasticsearch:confdir', '') %}
{% set elasticsearch_workdir = salt['pillar.get']('elasticsearch:workdir', '') %}


{% set is_master salt['grains.get']('master', '') %}
{% set is_data salt['grains.get']('data', '') %}
{% set is_ingest salt['grains.get']('ingest', '') %}
{% set is_coordinating salt['grains.get']('coordinating', '') %}
{% set minion_roles salt['grains.get']('roles', []) %}
{% set num_of_maters salt['grains.get']('num_of_masters', 0) %}
{% set master_name['grains.get']('master_name', '')}
elasticsearch-elasticsearch:
  group.present:
    - name: elasticsearch
  user.present:
    - name: elasticsearch
    - gid_from_name: True
    - groups:
      - elasticsearch

elasticsearch-create_elasticsearch_dir:
  file.directory:
    - name: {{elasticsearch_directory}}
    - user: root
    - group: root
    - dir_mode: 777
    - makedirs: True

elasticsearch-create_elasticsearch_datadir:
  file.directory:
    - name: {{elasticsearch_datadir}}
    - user: elasticsearch
    - group: elasticsearch
    - dir_mode: 755
    - makedirs: True

elasticsearch-create_elasticsearch_logdir:
  file.directory:
    - name: {{elasticsearch_logdir}}
    - user: elasticsearch
    - group: elasticsearch
    - dir_mode: 755
    - makedirs: True

elasticsearch-create_elasticsearch_confdir:
  file.directory:
    - name: {{elasticsearch_confdir}}
    - user: elasticsearch
    - group: elasticsearch
    - dir_mode: 755
    - makedirs: True

elasticsearch-create_elasticsearch_workdir:
  file.directory:
    - name: {{elasticsearch_workdir}}
    - user: elasticsearch
    - group: elasticsearch
    - dir_mode: 755
    - makedirs: True

elasticsearch-copy_configuration_elasticsearch:
  file.managed:
    - source: salt://elasticsearch/files/templates/elasticsearch.yml.tpl
    - user: elasticsearch
    - group: elasticsearch
    - name: {{elasticsearch_confdir}}/elasticsearch.yml
    - template: jinja

elasticsearch-dl_and_extract_elasticsearch:
  archive.extracted:
    - name: {{elasticsearch_directory}}
    - source: https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-{{ elasticsearch_version }}.tar.gz
    - source_hash: https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-{{ elasticsearch_version }}.tar.gz.sha1.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{elasticsearch_directory}}/elasticsearch-{{ elasticsearch_version }}

/etc/init/elasticsearch.conf:
  file.managed:
    - source: salt://elasticsearch/files/templates/elasticsearch.init.conf.tpl
    - mode: 644
    - template: jinja
    - context:
      cluster_name: {{cluster_name}}
      installdir: {{elasticsearch_directory}}/elasticsearch-{{ elasticsearch_version }}
      logdir: {{elasticsearch_logdir }}
      datadir: {{elasticsearch_datadir }}
      confdir: {{elasticsearch_confdir }}
      workdir: {{elasticsearch_workdir }}
      defaultconfig: {{elasticsearch_confdir}}/elasticsearch.yml
      is_master: {{is_master}}
      is_data: {{is_data}}
      is_ingest: {{is_ingest}}
      is_coordinating: {{is_coordinating}}
      minion_roles: {{minion_roles}}
      num_of_maters: {{num_of_master}}
      master_name: {{master_name}}

elasticsearch-service:
  service.running:
    - name: elasticsearch
    - enable: true
    - watch:
      - file: /etc/init/elasticsearch.conf

elastic-ulimit:
  cmd.run:
    - name: ulimit -Sn `ulimit -Hn`

elastic-sysctl:
  cmd.run:
    - name: sysctl -w vm.max_map_count=262144

