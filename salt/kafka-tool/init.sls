#read all pillar data
{% set flavor_cfg = pillar['pnda_flavor']['states']['kafka.server'] %}

{% set install_dir = pillar['pnda']['homedir'] %}
{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set release_directory = salt['pillar.get']('kafkatool:release_dir', '/opt/pnda') %}
{% set release_version = salt['pillar.get']('kafkatool:release_version', 'v0.2.0')  %}
{% set release_filename = 'kafka-tool-' + release_version + '.tar.gz' %}

{% set p  = salt['pillar.get']('kafka', {}) %}
{% set local_kafka_path = p.get('prefix', '/opt/pnda/kafka') %}
{% set kafka_log_path = flavor_cfg.data_dirs[0] %}

{%- set zk_ips = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_ips']() -%}
{%-   do zk_ips.append(ip + ':2181') -%}
{%- endfor -%}


kafka-tool-extract:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ packages_server }}/{{ release_filename }}
    - source_hash: {{ packages_server }}/{{ release_filename }}.sha512.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ release_directory }}/kafka-tool-{{ release_version }}

kafka-tool-create_link:
  file.symlink:
    - name: {{ release_directory }}/kafka-tool
    - target: {{ release_directory }}/kafka-tool-{{ release_version }}

kafka-tool-install_packages:
  pkg.installed:
    - pkgs:
      - {{ pillar['ruby-devel']['package-name'] }}
      - {{ pillar['g++']['package-name'] }}
      - {{ pillar['patch']['package-name'] }}

{% if grains['os'] == 'Ubuntu' %}
kafka-tool-install_build_essential:
  pkg.installed:
    - name: build-essential
{% endif %}

kafka-tool-install_gem_kafkat:
  cmd.run:
    - name: gem install --local kafkat-{{ release_version }}.gem
    - cwd: {{ release_directory }}/kafka-tool/


#Config file creation
kafka-tool-install_script:
  file.managed:
    - name: {{ release_directory }}/kafka-tool/kafkatcfg
    - source: salt://kafka-tool/templates/kafka-tool.conf.tpl
    - template: jinja
    - context:
      kafka_path: {{ local_kafka_path }}
      kafka_log_path: {{ kafka_log_path }}
      zk_ip_list: {{ zk_ips }}

kafka-tool-cfg_create_link:
  file.symlink:
    - name: /etc/kafkatcfg
    - target: {{ release_directory }}/kafka-tool/kafkatcfg

#by default kafkat is installed in /usr/local/bin, this is not in $PATH for RHEL. Create sym link in /usr/bin
{% if grains['os'] in ('RedHat', 'CentOS') %}
kafka-tool-bin_create_link:
  file.symlink:
    - name: /usr/bin/kafkat
    - target: /usr/local/bin/kafkat
{% endif %}

