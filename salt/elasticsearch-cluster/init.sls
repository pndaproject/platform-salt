{% set elasticsearch_version = salt['pillar.get']('elasticsearch-cluster:version', '') %}
{% set cluster_name = salt['pillar.get']('elasticsearch-cluster:name', '') %}
{% set elasticsearch_directory = salt['pillar.get']('elasticsearch-cluster:directory', '') %}
{% set elasticsearch_datadir = salt['pillar.get']('elasticsearch-cluster:datadir', '') %}
{% set elasticsearch_logdir = salt['pillar.get']('elasticsearch-cluster:logdir', '') %}
#{% set elasticsearch_confdir = salt['pillar.get']('elasticsearch-cluster:confdir', '') %}
{% set elasticsearch_workdir = salt['pillar.get']('elasticsearch-cluster:workdir', '') %}

{% set elasticsearch_confdir = elasticsearch_directory + '/elasticsearch-' + elasticsearch_version + '/config/' %}

{% set minion_roles = salt['grains.get']('roles', []) %}
{% set num_of_masters = salt['grains.get']('num_of_masters', 1) %}
{% set master_name = salt['grains.get']('master_name', '') %}
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
    - context:
      cluster_name: {{cluster_name}}
      minion_roles: {{minion_roles}}
      num_of_masters: {{num_of_masters}}
      master_name: {{master_name}}

elasticsearch-dl_and_extract_elasticsearch:
  archive.extracted:
    - name: {{elasticsearch_directory}}
    - source: https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-{{ elasticsearch_version }}.tar.gz
    - source_hash: https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-{{ elasticsearch_version }}.tar.gz.sha1
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

