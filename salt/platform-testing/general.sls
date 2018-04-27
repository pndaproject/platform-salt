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
{% set opentsdb_port = '4242' %}
{% set flink_history_server_port = '8082' %}
{% set data_service_port = '7000' %}
{% set metric_console_port = '3123' %}
{% set gobblin_cron_interval = 30 %}
{% set gobblin_retry_count = 10 %}
{% set pnda_master_dataset_location = pillar['pnda']['master_dataset']['directory'] %}
{% set pnda_quarantine_dataset_location = pillar['pnda']['master_dataset']['quarantine_directory'] %}
{% set console_user = pillar['pnda']['user'] %}
{% set console_password = pillar['pnda']['password'] %}

{% set pnda_cluster = salt['pnda.cluster_name']() %}

{%- set kafka_brokers = [] -%}
{%- for ip in salt['pnda.kafka_brokers_hosts']() -%}
{%- do kafka_brokers.append(ip + ':' + kafka_jmx_port) -%}
{%- endfor -%}

{%- set kafka_zookeepers = [] -%}
{%- for ip in salt['pnda.kafka_zookeepers_hosts']() -%}
{%- do kafka_zookeepers.append(ip + ':' + zookeeper_port) -%}
{%- endfor -%}

{%- set opentsdb_hosts = [] -%}
{%- for ip in salt['pnda.opentsdb_hosts']() -%}
{%- do opentsdb_hosts.append(ip + ':' + opentsdb_port) -%}
{%- endfor -%}

{%- set data_service_hosts = [] -%}
{%- for ip in salt['pnda.get_hosts_for_role']('data_service') -%}
{%- do data_service_hosts.append("http://" + ip + ':' + data_service_port) -%}
{%- endfor -%}

{%- set console_hosts = [] -%}
{%- set metric_console_hosts = [] -%}
{%- for ip in salt['pnda.get_hosts_for_role']('console_backend_data_logger') -%}
{%- do console_hosts.append(ip + ':' + console_port) -%}
{%- do metric_console_hosts.append("http://" + ip + ':' + metric_console_port) -%}
{%- endfor -%}

{%- set dm_hosts = [] -%}
{%- set dm_nodes = salt['pnda.get_hosts_for_role']('deployment_manager') -%}
{%- if dm_nodes is not none and dm_nodes|length > 0 -%}
  {%- for ip in dm_nodes -%}
  {%- do dm_hosts.append("http://" + ip + ':' + dm_port) -%}
  {%- endfor -%}
{%- endif -%}

{%- set fh_hosts = [] -%}
{%- set fh_nodes = salt['pnda.get_hosts_for_role']('flink') -%}
{%- if fh_nodes is not none and fh_nodes|length > 0 -%}
  {%- for ip in fh_nodes -%}
    {%- do fh_hosts.append("http://" + ip + ':' + flink_history_server_port) -%}
  {%- endfor -%}
{%- endif -%}

include:
  - python-pip

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
    - tar_options: ''
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
    - name: /usr/lib/systemd/system/platform-testing-general-kafka.service
    - source: salt://platform-testing/templates/platform-testing-general-kafka.service.tpl
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
    - name: /bin/systemctl start platform-testing-general-kafka

platform-testing-general-install-requirements-zookeeper:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/zookeeper/requirements.txt
    - index_url: {{ pip_index_url }}
    - require:
      - virtualenv: platform-testing-general-create-venv

platform-testing-general-zookeeper-service:
  file.managed:
    - name: /usr/lib/systemd/system/platform-testing-general-zookeeper.service
    - source: salt://platform-testing/templates/platform-testing-general-zookeeper.service.tpl
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
    - name: /bin/systemctl start platform-testing-general-zookeeper

platform-testing-general-opentsdb-service:
  file.managed:
    - name: /usr/lib/systemd/system/platform-testing-general-opentsdb.service
    - source: salt://platform-testing/templates/platform-testing-general-opentsdb.service.tpl
    - mode: 644
    - template: jinja
    - context:
      platform_testing_directory: {{ platform_testing_directory }}
      platform_testing_package: {{ platform_testing_package }}
      console_hosts: {{ console_hosts }}
      opentsdb_hosts: {{ opentsdb_hosts }}

platform-testing-general-crontab-opentsdb:
  cron.present:
    - identifier: PLATFORM-TESTING-OPENTSDB
    - user: root
{% if opentsdb_hosts|length > 10 %}
    - minute: '*/2'
{% else %}
    - minute: '*'
{% endif %}
    - name: /bin/systemctl start platform-testing-general-opentsdb

platform-testing-general-dataset_service:
  file.managed:
    - name: /usr/lib/systemd/system/platform-testing-general-dataset.service
    - source: salt://platform-testing/templates/platform-testing-general-dataset.service.tpl
    - mode: 644
    - template: jinja
    - context:
      platform_testing_directory: {{ platform_testing_directory }}
      platform_testing_package: {{ platform_testing_package }}
      console_hosts: {{ console_hosts }}
      data_service_hosts: {{ data_service_hosts }}
      metric_console_hosts: {{ metric_console_hosts }}
      pnda_cluster: {{ pnda_cluster }}
      gobblin_cron_interval: {{ gobblin_cron_interval }}
      gobblin_retry_count: {{ gobblin_retry_count }}
      pnda_master_dataset_location: {{ pnda_master_dataset_location }}
      pnda_quarantine_dataset_location: {{ pnda_quarantine_dataset_location }}
      console_user: {{ console_user }}
      console_password: {{ console_password }}

platform-testing-general-crontab-dataset:
  cron.present:
    - identifier: PLATFORM-TESTING-DATASET
    - user: root
    - name: /bin/systemctl start platform-testing-general-dataset

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
    - source: salt://platform-testing/templates/platform-testing-general-dm-blackbox.service.tpl
    - name: /usr/lib/systemd/system/platform-testing-general-dm-blackbox.service
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
    - name: /bin/systemctl start platform-testing-general-dm-blackbox

{% endif %}

{%- if fh_hosts is not none and fh_hosts|length > 0 %}
platform-testing-general-install-requirements-flink:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/flink/requirements.txt
    - index_url: {{ pip_index_url }}
    - require:
      - virtualenv: platform-testing-general-create-venv

platform-testing-general-flink_service:
  file.managed:
    - source: salt://platform-testing/templates/platform-testing-general-flink.service.tpl
    - name: /usr/lib/systemd/system/platform-testing-general-flink.service
    - mode: 644
    - template: jinja
    - context:
      platform_testing_directory: {{ platform_testing_directory }}
      platform_testing_package: {{ platform_testing_package }}
      console_hosts: {{ console_hosts }}
      fh_hosts: {{ fh_hosts }}

platform-testing-general-crontab-flink:
  cron.present:
    - identifier: PLATFORM-TESTING-FLINK
    - user: root
    - name: /bin/systemctl start platform-testing-general-flink

{% endif %}

platform-testing-general-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload
