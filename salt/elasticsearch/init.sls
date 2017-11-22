{% set flavor_cfg = pillar['pnda_flavor']['states'][sls] %}

{% set es_p = pillar['elasticsearch'] %}
{% do es_p.update({'directory': es_p.directory + '/elasticsearch-' + es_p.version}) %}

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set elasticsearch_package = 'elasticsearch-' + es_p.version + '.tar.gz' %}
{% set elasticsearch_url = mirror_location + elasticsearch_package %}

elasticsearch-elasticsearch:
  group.present:
    - name: elasticsearch
  user.present:
    - name: elasticsearch
    - gid_from_name: True
    - groups:
      - elasticsearch

elasticsearch-create_elasticsearch_datadir:
  file.directory:
    - name: {{ flavor_cfg.datadir }}
    - user: elasticsearch
    - group: elasticsearch
    - dir_mode: 755
    - makedirs: True

elasticsearch-create_elasticsearch_logdir:
  file.directory:
    - name: {{ es_p.logdir }}
    - user: elasticsearch
    - group: elasticsearch
    - dir_mode: 755
    - makedirs: True

elasticsearch-create_elasticsearch_confdir:
  file.directory:
    - name: {{ es_p.confdir }}
    - user: elasticsearch
    - group: elasticsearch
    - dir_mode: 755
    - makedirs: True

elasticsearch-create_elasticsearch_workdir:
  file.directory:
    - name: {{ es_p.workdir }}
    - user: elasticsearch
    - group: elasticsearch
    - dir_mode: 755
    - makedirs: True

elasticsearch-copy_configuration_elasticsearch:
  file.managed:
    - source: salt://elasticsearch/templates/elasticsearch.yml.tpl
    - user: elasticsearch
    - group: elasticsearch
    - name: {{ es_p.confdir }}/elasticsearch.yml
    - template: jinja

elasticsearch-dl_and_extract_elasticsearch:
  archive.extracted:
    - name: {{ es_p.directory }}
    - source: {{ elasticsearch_url }}
    - source_hash: {{ elasticsearch_url }}.sha1.txt
    - user: elasticsearch
    - group: elasticsearch
    - archive_format: tar
    - tar_options: --strip-components=1
    - if_missing: {{ es_p.directory }}/bin/elasticsearch

{% if grains['os'] == 'Ubuntu' %}
/etc/init/elasticsearch.conf:
  file.managed:
    - source: salt://elasticsearch/templates/elasticsearch.init.conf.tpl
{% elif grains['os'] in ('RedHat', 'CentOS') %}
/usr/lib/systemd/system/elasticsearch.service:
  file.managed:
    - source: salt://elasticsearch/templates/elasticsearch.service.tpl
{% endif %}
    - mode: 644
    - template: jinja
    - context:
      installdir: {{ es_p.directory }}
      logdir: {{ es_p.logdir }}
      datadir: {{ flavor_cfg.datadir }}
      confdir: {{ es_p.confdir }}
      workdir: {{ es_p.workdir }}
      defaultconfig: {{ es_p.confdir }}/elasticsearch.yml

{% if grains['os'] in ('RedHat', 'CentOS') %}
elasticsearch-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable elasticsearch
{%- endif %}

elasticsearch-start_service:
  cmd.run:
    - name: 'service elasticsearch stop || echo already stopped; service elasticsearch start'

