{% set elasticsearch_version = salt['pillar.get']('elasticsearch:version', '') %}
{% set elasticsearch_directory = salt['pillar.get']('elasticsearch:directory', '') %}
{% set elasticsearch_datadir = salt['pillar.get']('elasticsearch:datadir', '') %}
{% set elasticsearch_logdir = salt['pillar.get']('elasticsearch:logdir', '') %}
{% set elasticsearch_confdir = salt['pillar.get']('elasticsearch:confdir', '') %}
{% set elasticsearch_workdir = salt['pillar.get']('elasticsearch:workdir', '') %}

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set elasticsearch_version = pillar['elasticsearch']['version'] %}
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
    - source: salt://elasticsearch/templates/elasticsearch.yml.tpl
    - user: elasticsearch
    - group: elasticsearch
    - name: {{elasticsearch_confdir}}/elasticsearch.yml
    - template: jinja

elasticsearch-dl_and_extract_elasticsearch:
  archive.extracted:
    - name: {{elasticsearch_directory}}
    - source: {{ elasticsearch_url }}
    - source_hash: {{ elasticsearch_url }}.sha1.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{elasticsearch_directory}}/elasticsearch-{{ elasticsearch_version }}

{% if grains['os'] == 'Ubuntu' %}
/etc/init/elasticsearch.conf:
  file.managed:
    - source: salt://elasticsearch/templates/elasticsearch.init.conf.tpl
{% elif grains['os'] == 'RedHat' %}
/usr/lib/systemd/system/elasticsearch.service:
  file.managed:
    - source: salt://elasticsearch/templates/elasticsearch.service.tpl
{% endif %}
    - mode: 644
    - template: jinja
    - context:
      installdir: {{elasticsearch_directory}}/elasticsearch-{{ elasticsearch_version }}
      logdir: {{elasticsearch_logdir }}
      datadir: {{elasticsearch_datadir }}
      confdir: {{elasticsearch_confdir }}
      workdir: {{elasticsearch_workdir }}
      defaultconfig: {{elasticsearch_confdir}}/elasticsearch.yml

{% if grains['os'] == 'RedHat' %}
elasticsearch-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable elasticsearch
{%- endif %}

elasticsearch-start_service:
  cmd.run:
    - name: 'service elasticsearch stop || echo already stopped; service elasticsearch start'

