{% set elasticsearch_version = salt['pillar.get']('elasticsearch-cluster:version', '5.0.0') %}
{% set cluster_name = salt['pillar.get']('elasticsearch-cluster:name', '') %}
{% set elasticsearch_directory = salt['pillar.get']('elasticsearch-cluster:directory', '') %}
{% set elasticsearch_datadir = salt['pillar.get']('elasticsearch-cluster:datadir', '') %}
{% set elasticsearch_logdir = salt['pillar.get']('elasticsearch-cluster:logdir', '') %}
#{% set elasticsearch_confdir = salt['pillar.get']('elasticsearch-cluster:confdir', '') %}
{% set elasticsearch_workdir = salt['pillar.get']('elasticsearch-cluster:workdir', '') %}
{% set elasticsearch_pluginsdir =  elasticsearch_directory + '/elasticsearch-' + elasticsearch_version + '/plugins' %}
{% set elasticsearch_confdir = elasticsearch_directory + '/elasticsearch-' + elasticsearch_version + '/config' %}
{% set extra_mirror = salt['pillar.get']('extra:mirror', 'https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch/') %}
{% set elasticsearch_url = extra_mirror +  'elasticsearch-' +  elasticsearch_version + '.tar.gz' %}

{% set minion_roles = salt['grains.get']('roles', []) %}
{% set num_of_masters = salt['grains.get']('num_of_masters', 1) %}
{% set master_name = salt['grains.get']('master_name', '') %}

{%- set pnda_cluster = salt['pnda.cluster_name']() %}
{%- set es_master_grains = salt['mine.get']('G@pnda_cluster:{} and G@roles:elk-es-master'.format(pnda_cluster), 'grains.items',
expr_form='compound') %}

{% set es_master_hostnames = [] %}
{% for grains in es_master_grains.values() %}
  {% do es_master_hostnames.append(grains['fqdn']) %}
{% endfor %}

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

elasticsearch-dl_and_extract_elasticsearch:
  archive.extracted:
    - name: {{elasticsearch_directory}}
    - source: {{ elasticsearch_url }}
    - source_hash:{{ elasticsearch_url }}.sha1.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{elasticsearch_directory}}/elasticsearch-{{ elasticsearch_version }}

elasticsearch-create_elasticsearch_confdir:
  file.directory:
    - name: {{elasticsearch_confdir}}
    - user: elasticsearch
    - group: elasticsearch
    - dir_mode: 755
    - makedirs: True

elasticsearch-create_elasticsearch_pluginsdir:
  file.directory:
    - name: {{elasticsearch_pluginsdir}}
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
    - source: salt://elasticsearch-cluster/files/templates/elasticsearch.yml.tpl
    - user: elasticsearch
    - group: elasticsearch
    - name: {{elasticsearch_confdir}}/elasticsearch.yml
    - template: jinja
    - context:
      logdir: {{elasticsearch_logdir }}
      cluster_name: {{cluster_name}}
      minion_roles: {{minion_roles}}
      num_of_masters: {{num_of_masters}}
      master_name: {{master_name}}
      list_of_masters: {{ es_master_hostnames }}

/etc/init/elasticsearch.conf:
  file.managed:
    - source: salt://elasticsearch-cluster/files/templates/elasticsearch.init.conf.tpl
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
  sysctl.present:
    - name: vm.max_map_count
    - value: 262144

