{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set platform_testing_version = salt['pillar.get']('platform_testing:release_version', '0.2.7') %}
{% set platform_testing_directory = salt['pillar.get']('platform_testing:release_directory', '/opt/pnda') %}

{% set platform_testing_package = 'platform-testing-general' %}

{% set virtual_env_dir = platform_testing_directory + "/" + platform_testing_package + "-" + platform_testing_version + "/venv" %}
{% set pip_index_url = pillar['pip']['index_url'] %}

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

{% if grains['os'] == 'RedHat' %}
platform-testing-general-install_dev_deps_nmap_ncat:
  pkg.installed:
    - name: {{ pillar['nmap-ncat']['package-name'] }}
    - version: {{ pillar['nmap-ncat']['version'] }}
    - ignore_epoch: True

platform-testing-general-install_dev_deps_cyrus:
  pkg.installed:
    - name: {{ pillar['cyrus-sasl-devel']['package-name'] }}
    - version: {{ pillar['cyrus-sasl-devel']['version'] }}
    - ignore_epoch: True
{% endif %}

platform-testing-general-install_dev_deps_sasl:
  pkg.installed:
    - name: {{ pillar['libsasl']['package-name'] }}
    - version: {{ pillar['libsasl']['version'] }}
    - ignore_epoch: True

platform-testing-general-install_dev_deps_gcc:
  pkg.installed:
    - name: {{ pillar['g++']['package-name'] }}
    - version: {{ pillar['g++']['version'] }}
    - ignore_epoch: True

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
    - python: python2
    - index_url: {{ pip_index_url }}
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
    - index_url: {{ pip_index_url }}
    - require:
      - virtualenv: platform-testing-general-create-venv

platform-testing-general-kafka_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - source: salt://platform-testing/templates/platform-testing-general-kafka.conf.tpl
    - name: /etc/init/platform-testing-general-kafka.conf
{% elif grains['os'] == 'RedHat' %}
    - name: /usr/lib/systemd/system/platform-testing-general-kafka.service
    - source: salt://platform-testing/templates/platform-testing-general-kafka.service.tpl
{% endif %}
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
{% if grains['os'] == 'Ubuntu' %}
    - name: /sbin/start platform-testing-general-kafka
{% elif grains['os'] == 'RedHat' %}
    - name: /bin/systemctl start platform-testing-general-kafka
{% endif %}

platform-testing-general-install-requirements-zookeeper:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/zookeeper/requirements.txt
    - index_url: {{ pip_index_url }}
    - require:
      - virtualenv: platform-testing-general-create-venv

platform-testing-general-zookeeper-service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - source: salt://platform-testing/templates/platform-testing-general-zookeeper.conf.tpl
    - name: /etc/init/platform-testing-general-zookeeper.conf
{% elif grains['os'] == 'RedHat' %}
    - name: /usr/lib/systemd/system/platform-testing-general-zookeeper.service
    - source: salt://platform-testing/templates/platform-testing-general-zookeeper.service.tpl
{% endif %}
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
{% if grains['os'] == 'Ubuntu' %}
    - name: /sbin/start platform-testing-general-zookeeper
{% elif grains['os'] == 'RedHat' %}
    - name: /bin/systemctl start platform-testing-general-zookeeper
{% endif %}

{%- if dm_hosts is not none and dm_hosts|length > 0 %}
platform-testing-general-install-requirements-dm-blackbox:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/dm_blackbox/requirements.txt
    - index_url: {{ pip_index_url }}
    - require:
      - virtualenv: platform-testing-general-create-venv

platform-testing-general-dm-blackbox_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - source: salt://platform-testing/templates/platform-testing-general-dm-blackbox.conf.tpl
    - name: /etc/init/platform-testing-general-dm-blackbox.conf
{% elif grains['os'] == 'RedHat' %}
    - source: salt://platform-testing/templates/platform-testing-general-dm-blackbox.service.tpl
    - name: /usr/lib/systemd/system/platform-testing-general-dm-blackbox.service
{%- endif %}
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
{% if grains['os'] == 'Ubuntu' %}
    - name: /sbin/start platform-testing-general-dm-blackbox
{% elif grains['os'] == 'RedHat' %}
    - name: /bin/systemctl start platform-testing-general-dm-blackbox
{% endif %}

{% endif %}

{% if grains['os'] == 'RedHat' %}
platform-testing-general-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload
{%- endif %}

