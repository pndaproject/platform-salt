{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set platform_testing_version = salt['pillar.get']('platform_testing:release_version', '0.2.7') %}
{% set platform_testing_directory = salt['pillar.get']('platform_testing:release_directory', '/opt/pnda') %}

{% set platform_testing_package = 'platform-testing-general' %}

{% set kafka_jmx_port = '9050' %}
{% set console_port = '3001' %}
{% set zookeeper_port = '2181' %}
{% set dm_port = '5000' %}

{% set pnda_cluster = salt['pnda.cluster_name']() %}

{%- set kafka_brokers = [] -%}
{%- for ip in salt['pnda.kafka_brokers_ips']() -%}
{%- do kafka_brokers.append(ip + ':' + kafka_jmx_port) -%}
{%- endfor -%}

{%- set kafka_zookeepers = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_ips']() -%}
{%- do kafka_zookeepers.append(ip + ':' + zookeeper_port) -%}
{%- endfor -%}

{%- set console_hosts = [] -%}
{%- for ip in salt['pnda.ip_addresses']('console_backend') -%}
{%- do console_hosts.append(ip + ':' + console_port) -%}
{%- endfor -%}

{% set dm_hosts = [] %}
{%- for ip in salt['pnda.ip_addresses']('deployment_manager') -%}
{%- do dm_hosts.append("http://" + ip + ':' + dm_port) -%}
{%- endfor -%}

include:
  - python-pip

platform-testing-general-install_dev_deps:
  pkg.installed:
    - pkgs:
      - libsasl2-dev
      - g++

platform-testing-general-install_python_deps:
  pip.installed:
    - pkgs:
      - setuptools == 3.4.4
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip

platform-testing-cdh-dl-and-extract:
  archive.extracted:
    - name: {{ platform_testing_directory }} 
    - source: {{ packages_server }}/platform/releases/platform-testing/{{platform_testing_package}}-{{ platform_testing_version }}.tar.gz
    - source_hash: {{ packages_server }}/platform/releases/platform-testing/{{platform_testing_package}}-{{ platform_testing_version }}.tar.gz.sha512.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }} 

platform-testing-general-install-requirements:
  pip.installed:
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/requirements.txt
    - require:
      - pip: python-pip-install_python_pip

platform-testing-general-create-link:
  file.symlink:
    - name: {{ platform_testing_directory }}/{{platform_testing_package}}
    - target: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}

platform-testing-general-install-requirements-kafka:
  pip.installed:
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/kafka/requirements.txt
    - require:
      - pip: python-pip-install_python_pip

platform-testing-general-kafka_upstart:
  file.managed:
    - source: salt://platform-testing/templates/platform-testing-general-kafka.conf.tpl
    - name: /etc/init/platform-testing-general-kafka.conf
    - mode: 644
    - template: jinja
    - context:
      platform_testing_directory: {{ platform_testing_directory }}
      platform_testing_package: {{ platform_testing_package }}
      console_hosts: {{ console_hosts }}
      kafka_brokers: {{ kafka_brokers }}
      kafka_zookeepers: {{ kafka_zookeepers }}

platform-testing-general-crontab-kafka:
  cron.present:
    - identifier: PLATFORM-TESTING-KAFKA
    - user: root
    - name: sudo service platform-testing-general-kafka start

platform-testing-general-install-requirements-kafka-blackbox:
  pip.installed:
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/kafka_blackbox/requirements.txt
    - require:
      - pip: python-pip-install_python_pip

platform-testing-general-kafka-blackbox_upstart:
  file.managed:
    - source: salt://platform-testing/templates/platform-testing-general-kafka-blackbox.conf.tpl
    - name: /etc/init/platform-testing-general-kafka-blackbox.conf
    - mode: 644
    - template: jinja
    - context:
      platform_testing_directory: {{ platform_testing_directory }}
      platform_testing_package: {{ platform_testing_package }}
      console_hosts: {{ console_hosts }}
      kafka_zookeepers: {{ kafka_zookeepers }}

platform-testing-general-crontab-kafka-blackbox:
  cron.present:
    - identifier: PLATFORM-TESTING-KAFKA-BLACKBOX
    - user: root
    - name: sudo service platform-testing-general-kafka-blackbox start

platform-testing-general-install-requirements-zookeeper-blackbox:
  pip.installed:
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/zookeeper_blackbox/requirements.txt
    - require:
      - pip: python-pip-install_python_pip

platform-testing-general-zookeeper-blackbox_upstart:
  file.managed:
    - source: salt://platform-testing/templates/platform-testing-general-zookeeper-blackbox.conf.tpl
    - name: /etc/init/platform-testing-general-zookeeper-blackbox.conf
    - mode: 644
    - template: jinja
    - context:
      platform_testing_directory: {{ platform_testing_directory }}
      platform_testing_package: {{ platform_testing_package }}
      console_hosts: {{ console_hosts }}
      kafka_zookeepers: {{ kafka_zookeepers }}

platform-testing-general-crontab-zookeeper-blackbox:
  cron.present:
    - identifier: PLATFORM-TESTING-ZOOKEEPER
    - user: root
    - name: sudo service platform-testing-general-zookeeper-blackbox start

platform-testing-general-install-requirements-dm-blackbox:
  pip.installed:
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/dm_blackbox/requirements.txt
    - require:
      - pip: python-pip-install_python_pip

platform-testing-general-dm-blackbox_upstart:
  file.managed:
    - source: salt://platform-testing/templates/platform-testing-general-dm-blackbox.conf.tpl
    - name: /etc/init/platform-testing-general-dm-blackbox.conf
    - mode: 644
    - template: jinja
    - context:
      platform_testing_directory: {{ platform_testing_directory }}
      platform_testing_package: {{ platform_testing_package }}
      console_hosts: {{ console_hosts }}
      dm_hosts: {{ dm_hosts }}

platform-testing-general-crontab-dm-blackbox:
  cron.present:
    - identifier: PLATFORM-TESTING-DM-BLACKBOX
    - user: root
    - name: sudo service platform-testing-general-dm-blackbox start

platform-testing-general-crontab-reload:
  service.running:
    - name: cron
    - reload: True
