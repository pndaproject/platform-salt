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

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set logstash_version = pillar['logstash-cluster']['version'] %}
{% set logstash_package = 'logstash-' + logstash_version + '.tar.gz' %}
{% set logstash_url = mirror_location + logstash_package %}

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
    - source: {{ logstash_url }}
    - source_hash: {{ logstash_url }}.sha1
    - archive_format: tar
    - tar_options: ''
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
    - source: salt://logstash/templates/logstash.conf.tpl
    - user: logstash
    - group: logstash
    - name: {{logstash_confdir}}/logstash.conf
    - template: jinja
    - context:
      list_of_ingest: {{ es_ingest_hostnames }}
      input_dir: {{logstash_inputdir}}/*

{% if grains['os'] == 'Ubuntu' %}
/etc/init/logstash.conf:
  file.managed:
    - source: salt://logstash/templates/logstash.init.conf.tpl
{% elif grains['os'] in ('RedHat', 'CentOS') %}
/usr/lib/systemd/system/logstash.service:
  file.managed:
    - source: salt://logstash/templates/logstash.service.tpl  
{% endif %}
    - mode: 644
    - template: jinja
    - context:
      installdir: {{logstash_directory}}/logstash-{{ logstash_version }}
      logdir: {{logstash_logdir }}
      confpath: {{logstash_confdir }}/logstash.conf
      datadir: {{logstash_datadir}}

{% if grains['os'] in ('RedHat', 'CentOS') %}
logstash-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable logstash
{%- endif %}

logstash-start_service:
  cmd.run:
    - name: 'service logstash stop || echo already stopped; service logstash start'

