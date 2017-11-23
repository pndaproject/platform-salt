{% set settings = salt['pillar.get']('zookeeper', {}) -%}
{% set flavor_cfg = pillar['pnda_flavor']['states'][sls] %}

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set zookeeper_version = pillar['zookeeper']['version'] %}
{% set zookeeper_package = 'zookeeper-' + zookeeper_version + '.tar.gz' %}
{% set zookeeper_url = mirror_location + zookeeper_package %}

{% set install_dir = pillar['pnda']['homedir'] %}

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
    - name: {{ flavor_cfg.zookeeper_data_dir }}
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
    - name: {{ flavor_cfg.zookeeper_data_dir }}/myid
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
    - mode: 755
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
      data_dir: {{ flavor_cfg.zookeeper_data_dir }}
    - mode: 644

zookeeper-environment:
  file.managed:
    - name: {{ install_dir }}/zookeeper-{{ zookeeper_version }}/conf/environment
    - source: salt://zookeeper/files/templates/environment.tpl
    - template: jinja
    - context:
      install_dir: {{ install_dir }}/zookeeper-{{ zookeeper_version }}
      heap_size: {{ flavor_cfg.zookeeper_heapsize }}
    - mode: 644

zookeeper-link:
  file.symlink:
    - name: /usr/share/java/zookeeper.jar
    - target: {{ install_dir }}/zookeeper-{{ zookeeper_version }}/zookeeper-{{ zookeeper_version }}.jar
    - require:
      - archive: zookeeper-dl-and-extract

{% if grains['os'] == 'Ubuntu' %}
zookeeper-service:
  file.managed:
    - name: /etc/init/zookeeper.conf
    - source: salt://zookeeper/files/templates/zookeeper.init.conf.tpl
    - template: jinja
    - context:
      conf_dir: {{ install_dir }}/zookeeper-{{ zookeeper_version }}/conf
    - mode: 644
    - require:
      - file: zookeeper-data-dir
{% elif grains['os'] in ('RedHat', 'CentOS') %}
zookeeper-service_startpre:
    file.managed:
      - name: {{ install_dir }}/zookeeper-{{ zookeeper_version }}/bin/zookeeper-service-startpre.sh
      - source: salt://zookeeper/files/templates/zookeeper-service-startpre.sh.tpl
      - template: jinja
      - context:
        conf_dir: {{ install_dir }}/zookeeper-{{ zookeeper_version }}/conf
      - mode: 755
      - require:
        - file: zookeeper-data-dir

zookeper-service_start:
    file.managed:
      - name: {{ install_dir }}/zookeeper-{{ zookeeper_version }}/bin/zookeeper-service-start.sh
      - source: salt://zookeeper/files/templates/zookeeper-service-start.sh.tpl
      - template: jinja
      - context:
        conf_dir: {{ install_dir }}/zookeeper-{{ zookeeper_version }}/conf
      - mode: 755
      - require:
        - file: zookeeper-data-dir

zookeeper-systemd:
  file.managed:
    - name: /usr/lib/systemd/system/zookeeper.service
    - source: salt://zookeeper/files/templates/zookeeper.service.tpl
    - template: jinja
    - context:
      conf_dir: {{ install_dir }}/zookeeper-{{ zookeeper_version }}/conf
    - mode: 644
    - require:
      - file: zookeeper-data-dir
{% endif %}

{% if grains['os'] in ('RedHat', 'CentOS') %}
zookeeper-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable zookeeper
{%- endif %}

zookeeper-ensure-service-running:
  cmd.run:
    - name: 'service zookeeper stop || echo already stopped; service zookeeper start'
