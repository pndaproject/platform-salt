{% set settings = salt['pillar.get']('zookeeper', {}) -%}
{% set zookeeper_version = settings.get('version', '3.4.6') %}
{% set zookeeper_url  = 'http://www-us.apache.org/dist/zookeeper/zookeeper-' + zookeeper_version + '/zookeeper-' + zookeeper_version + '.tar.gz' %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set zookeeper_data_dir = '/var/lib/zookeeper' %}

zookeeper-user-group:
  group.present:
    - name: zookeeper
  user.present:
    - name: zookeeper
    - gid_from_name: True
    - groups:
      - zookeeper

zookeeper-data-dir:
  file.directory:
    - name: {{ zookeeper_data_dir }}
    - user: zookeeper
    - group: zookeeper
    - mode: 755
    - makedirs: True
    - recurse:
      - user
      - group
      - mode
    - require:
      - user: zookeeper-user-group

zookeeper-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }} 
    - source: {{ zookeeper_url }}
    - source_hash: {{ zookeeper_url }}.sha1
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ install_dir }}/zookeeper-{{ zookeeper_version }} 

{% set nodes = [] %}
{% include "zookeeper/nodes.sls" %}

zookeeper-myid:
  file.managed:
    - name: {{ zookeeper_data_dir }}/myid
    - source: salt://zookeeper/files/templates/zookeeper-myid.tpl
    - template: jinja
    - context:
      nodes:
      {%- for node in nodes %}
        -
          id: {{ node.id }}
          ip: {{ node.ip }}
          fqdn: {{ node.fqdn }}
      {%- endfor %}
    - mode: 644
    - require:
      - file: zookeeper-data-dir

zookeeper-configuration:
  file.managed:
    - name: {{ install_dir }}/zookeeper-{{ zookeeper_version }}/conf/zoo.cfg
    - source: salt://zookeeper/files/templates/zoo.cfg.tpl
    - template: jinja
    - context:
      nodes:
      {%- for node in nodes %}
        -
          id: {{ node.id }}
          ip: {{ node.ip }}
          fqdn: {{ node.fqdn }}
      {%- endfor %}
      data_dir: {{ zookeeper_data_dir }}
    - mode: 644

zookeeper-environment:
  file.managed:
    - name: {{ install_dir }}/zookeeper-{{ zookeeper_version }}/conf/environment
    - source: salt://zookeeper/files/templates/environment.tpl
    - template: jinja
    - context:
      install_dir: {{ install_dir }}/zookeeper-{{ zookeeper_version }}
    - mode: 644

zookeeper-link:
  file.symlink:
    - name: /usr/share/java/zookeeper.jar
    - target: {{ install_dir }}/zookeeper-{{ zookeeper_version }}/zookeeper-{{ zookeeper_version }}.jar
    - require:
      - archive: zookeeper-dl-and-extract

zookeeper-upstart:
  file.managed:
    - name: /etc/init/zookeeper.conf
    - source: salt://zookeeper/files/templates/zookeeper.init.conf.tpl
    - template: jinja
    - context:
      conf_dir: {{ install_dir }}/zookeeper-{{ zookeeper_version }}/conf
    - mode: 644
    - require:
      - file: zookeeper-data-dir

zookeeper-ensure-service-running:
  service.running:
    - name: zookeeper
    - watch:
      - archive: zookeeper-dl-and-extract
      - file: zookeeper-environment
      - file: zookeeper-configuration
      - file: zookeeper-myid
      - file: zookeeper-upstart
      - file: zookeeper-link
