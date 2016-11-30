{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set platform_testing_version = salt['pillar.get']('platform_testing:release_version', '0.2.7') %}
{% set platform_testing_directory = salt['pillar.get']('platform_testing:release_directory', '/opt/pnda') %}

{% set platform_testing_package = 'platform-testing-general' %}

{% set virtual_env_dir = platform_testing_directory + "/" + platform_testing_package + "-" + platform_testing_version + "/venv" %}

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
{%- for ip in salt['pnda.ip_addresses']('console_backend_data_logger') -%}
{%- do console_hosts.append(ip + ':' + console_port) -%}
{%- endfor -%}

{%- set dm_hosts = [] -%}
{%- set dm_nodes = salt['pnda.ip_addresses']('deployment_manager') -%}
{%- if dm_nodes is not none and dm_nodes|length > 0 -%}
  {%- for ip in dm_nodes -%}
  {%- do dm_hosts.append("http://" + ip + ':' + dm_port) -%}
  {%- endfor -%}
{%- endif -%}

include:
  - python-pip

platform-testing-general-install_dev_deps:
  pkg.installed:
    - pkgs:
      - libsasl2-dev
      - g++

platform-testing-general-dl-and-extract:
  archive.extracted:
    - name: {{ platform_testing_directory }}
    - source: {{ packages_server }}/{{platform_testing_package}}-{{ platform_testing_version }}.tar.gz
    - source_hash: {{ packages_server }}/{{platform_testing_package}}-{{ platform_testing_version }}.tar.gz.sha512.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}

platform-testing-general-create-venv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/requirements.txt
    - require:
      - pip: python-pip-install_python_pip
      - archive: platform-testing-general-dl-and-extract

platform-testing-general-create-link:
  file.symlink:
    - name: {{ platform_testing_directory }}/{{platform_testing_package}}
    - target: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}

platform-testing-general-install-requirements-kafka:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/kafka/requirements.txt
    - require:
      - virtualenv: platform-testing-general-create-venv

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
    - name: /sbin/start platform-testing-general-kafka

platform-testing-general-install-requirements-zookeeper:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/zookeeper/requirements.txt
    - require:
      - virtualenv: platform-testing-general-create-venv

platform-testing-general-zookeeper-upstart:
  file.managed:
    - source: salt://platform-testing/templates/platform-testing-general-zookeeper.conf.tpl
    - name: /etc/init/platform-testing-general-zookeeper.conf
    - mode: 644
    - template: jinja
    - context:
      platform_testing_directory: {{ platform_testing_directory }}
      platform_testing_package: {{ platform_testing_package }}
      console_hosts: {{ console_hosts }}
      kafka_zookeepers: {{ kafka_zookeepers }}

platform-testing-general-crontab-zookeeper:
  cron.present:
    - identifier: PLATFORM-TESTING-ZOOKEEPER
    - user: root
    - name: /sbin/start platform-testing-general-zookeeper

{%- if dm_hosts is not none and dm_hosts|length > 0 %}
platform-testing-general-install-requirements-dm-blackbox:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/dm_blackbox/requirements.txt
    - require:
      - virtualenv: platform-testing-general-create-venv

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
    - name: /sbin/start platform-testing-general-dm-blackbox
{%- endif %}
