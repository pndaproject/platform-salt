{% set elasticsearch_version = salt['pillar.get']('elasticsearch-cluster:version', '5.0.0') %}
{% set cluster_name = salt['pillar.get']('elasticsearch-cluster:name', '') %}
{% set elasticsearch_directory = salt['pillar.get']('elasticsearch-cluster:directory', '') %}
{% set elasticsearch_datadir = salt['pillar.get']('elasticsearch-cluster:datadir', '') %}
{% set elasticsearch_logdir = salt['pillar.get']('elasticsearch-cluster:logdir', '') %}
#{% set elasticsearch_confdir = salt['pillar.get']('elasticsearch-cluster:confdir', '') %}
{% set elasticsearch_workdir = salt['pillar.get']('elasticsearch-cluster:workdir', '') %}
{% set elasticsearch_pluginsdir =  elasticsearch_directory + '/elasticsearch-' + elasticsearch_version + '/plugins' %}
{% set elasticsearch_confdir = elasticsearch_directory + '/elasticsearch-' + elasticsearch_version + '/config' %}

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

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set elasticsearch_version = pillar['elasticsearch-cluster']['version'] %}
{% set elasticsearch_package = 'elasticsearch-' + elasticsearch_version + '.tar.gz' %}
{% set elasticsearch_url = mirror_location + elasticsearch_package %}

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
    - source_hash: {{ elasticsearch_url }}.sha1
    - archive_format: tar
    - tar_options: ''
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
    - source: salt://elasticsearch-cluster/templates/elasticsearch.yml.tpl
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

{% if grains['os'] == 'Ubuntu' %}
/etc/init/elasticsearch.conf:
  file.managed:
    - source: salt://elasticsearch-cluster/templates/elasticsearch.init.conf.tpl
{% elif grains['os'] in ('RedHat', 'CentOS') %}
/usr/lib/systemd/system/elasticsearch.service:
  file.managed:
    - source: salt://elasticsearch-cluster/templates/elasticsearch.service.tpl
{% endif %}
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

{% if grains['os'] in ('RedHat', 'CentOS') %}
elasticsearch-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable elasticsearch
{%- endif %}

elasticsearch-start_service:
  cmd.run:
    - name: 'service elasticsearch stop || echo already stopped; service elasticsearch start'

elastic-ulimit:
  cmd.run:
    - name: ulimit -Sn `ulimit -Hn`

elastic-sysctl:
  sysctl.present:
    - name: vm.max_map_count
    - value: 262144

