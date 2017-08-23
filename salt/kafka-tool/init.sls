#read all pillar data

{% set install_dir = pillar['pnda']['homedir'] %}
{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set release_directory = salt['pillar.get']('kafkatool:release_dir', '/opt/pnda') %}
{% set release_version = salt['pillar.get']('kafkatool:version', '0.3.0')  %}
{% set release_filename = 'kafka-tool-' + release_version + '.tar.gz' %}

{% set p  = salt['pillar.get']('kafka', {}) %}
{% set local_kafka_path = p.get('prefix', '/opt/pnda/kafka') %}
{% set p1  = salt['pillar.get']('kafkatool', {}) %}
{% set local_kafkat_log_path = p1.get('log_dir', '/var/log/pnda/kafkatool') %}

{%- set zk_ips = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_ips']() -%}
{%-   do zk_ips.append(ip + ':2181') -%}
{%- endfor -%}


kafkat-dl-and-extract:
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

install ruby:
  pkg.installed:
{% if grains['os'] == 'RedHat' %}
    - name: ruby-devel
{% elif grains['os'] == 'Ubuntu' %}
    - name: ruby-dev
{% endif %}


{% if grains['os'] == 'RedHat' %}
install ruby-devel:
  pkg.installed:
    - name: 'ruby-devel'
install gcc-c++:
  pkg.installed:
    - name: 'gcc-c++'
install patch:
  pkg.installed:
    - name: 'patch'
{% elif grains['os'] == 'Ubuntu' %}
install build-essential:
  pkg.installed:
    - name: build-essential
{% endif %}

# gem install kafakt-0.3.0
install-gem-kafkat:
  cmd.run:
    - name: gem install {{ release_directory }}/kafka-tool/kafkat-{{ release_version }}.gem
    - cwd: /


#Config file creation
kafka-tool-install-script:
  file.managed:
    - name: /etc/kafkatcfg
    - source: salt://kafka-tool/templates/kafka-tool.conf.tpl
    - template: jinja
    - context:
      kafka_path: {{ local_kafka_path }}
      kafkat_log_path: {{ local_kafkat_log_path }}
      zk_ip_list: {{ zk_ips }}

append-bashrc:
  file.append:
    - name: ~/.bashrc
    - text:  "export PATH=/usr/local/bin/:$PATH"

