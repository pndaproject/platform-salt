{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set platform_testing_version = salt['pillar.get']('platform_testing:release_version', '0.1.1') %}
{% set platform_testing_directory = salt['pillar.get']('platform_testing:release_directory', '/opt/pnda') %}

{% set platform_testing_package = 'platform-testing-cdh' %}

{%- if grains['hadoop.distro'] == 'CDH' -%}
{% set platform_testing_service = 'cdh' %}
{% set cm_port = '7180' %}
{%- else -%}
{% set platform_testing_service = 'hdp' %}
{% set cm_port = '8080' %}
{%- endif -%}

{% set virtual_env_dir = platform_testing_directory + "/" + platform_testing_package + "-" + platform_testing_version + "/venv" %}
{% set pip_index_url = pillar['pip']['index_url'] %}

{% set console_port = '3001' %}

{% set hive_node = salt['pnda.get_hosts_by_hadoop_role']('hive_server')[0] %}
{%- if grains['hadoop.distro'] == 'CDH' -%}
{% set hive_http_port = '10000' %}
{%- else -%}
{% set hive_http_port = '10001' %}
{%- endif -%}

{% set cm_hoststring = salt['pnda.hadoop_manager_ip']()  %}
{% set console_hoststring = salt['pnda.get_hosts_for_role']('console_backend_data_logger')[0] + ":" + console_port %}
{% set cm_username = pillar['admin_login']['user'] %}
{% set cm_password = pillar['admin_login']['password'] %}
{% set hadoop_distro = grains['hadoop.distro'] %}
{% set pnda_cluster = salt['pnda.cluster_name']() %}

include:
  - python-pip

platform-testing-cdh-dl-and-extract:
  archive.extracted:
    - name: {{ platform_testing_directory }}
    - source: {{ packages_server }}/{{platform_testing_package}}-{{ platform_testing_version }}.tar.gz
    - source_hash: {{ packages_server }}/{{ platform_testing_package }}-{{ platform_testing_version }}.tar.gz.sha512.txt
    - archive_format: tar
    - tar_options: ''
    - if_missing: {{ platform_testing_directory }}/{{ platform_testing_package }}-{{ platform_testing_version }}

platform-testing-cdh-install_dev_deps_cyrus:
  pkg.installed:
    - name: {{ pillar['cyrus-sasl-devel']['package-name'] }}
    - version: {{ pillar['cyrus-sasl-devel']['version'] }}
    - ignore_epoch: True

platform-testing-cdh-install_dev_deps_cyrus_gssapi:
  pkg.installed:
    - name: {{ pillar['cyrus-sasl-gssapi']['package-name'] }}
    - version: {{ pillar['cyrus-sasl-gssapi']['version'] }}
    - ignore_epoch: True

platform-testing-cdh-install_dev_deps_cyrus_plain:
  pkg.installed:
    - name: {{ pillar['cyrus-sasl-plain']['package-name'] }}
    - version: {{ pillar['cyrus-sasl-plain']['version'] }}
    - ignore_epoch: True

platform-testing-cdh-install_dev_deps_sasl:
  pkg.installed:
    - name: {{ pillar['libsasl']['package-name'] }}
    - version: {{ pillar['libsasl']['version'] }}
    - ignore_epoch: True

platform-testing-cdh-install_dev_deps_gcc:
  pkg.installed:
    - name: {{ pillar['g++']['package-name'] }}
    - version: {{ pillar['g++']['version'] }}
    - ignore_epoch: True

platform-testing-cdh-create-venv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{ platform_testing_package }}-{{ platform_testing_version }}/requirements.txt
    - python: python2
    - index_url: {{ pip_index_url }}
    - require:
      - pip: python-pip-install_python_pip
      - archive: platform-testing-cdh-dl-and-extract


platform-testing-cdh-create-link:
  file.symlink:
    - name: {{ platform_testing_directory }}/{{ platform_testing_package }}
    - target: {{ platform_testing_directory }}/{{ platform_testing_package }}-{{ platform_testing_version }}

platform-testing-cdh-install-requirements-cdh:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/cdh/requirements.txt
    - index_url: {{ pip_index_url }}
    - require:
      - virtualenv: platform-testing-cdh-create-venv

platform-testing-cdh_service:
  file.managed:
    - source: salt://platform-testing/templates/platform-testing-{{ platform_testing_service }}.service.tpl
    - name: /usr/lib/systemd/system/platform-testing-cdh.service
    - mode: 644
    - template: jinja
    - context:
      platform_testing_directory: {{ platform_testing_directory }}
      platform_testing_package: {{ platform_testing_package }}
      console_hoststring: {{ console_hoststring }}
      cm_hoststring: {{ cm_hoststring }}
      cm_port: {{ cm_port }}
      cm_username: {{ cm_username }}
      cm_password: {{ cm_password }}
      cluster_name: {{ pnda_cluster }}

platform-testing-cdh-crontab-cdh:
  cron.present:
    - identifier: PLATFORM-TESTING-CDH
    - user: root
    - name: /bin/systemctl start platform-testing-cdh
    - require:
      - pip: platform-testing-cdh-install-requirements-cdh
      - file: platform-testing-cdh_service

platform-testing-cdh-install-requirements-cdh_blackbox:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/cdh_blackbox/requirements.txt
    - index_url: {{ pip_index_url }}
    - require:
      - virtualenv: platform-testing-cdh-create-venv

platform-testing-cdh-blackbox_service:
  file.managed:
    - source: salt://platform-testing/templates/platform-testing-cdh-blackbox.service.tpl
    - name: /usr/lib/systemd/system/platform-testing-cdh-blackbox.service
    - mode: 644
    - template: jinja
    - context:
      platform_testing_directory: {{ platform_testing_directory }}
      platform_testing_package: {{ platform_testing_package }}
      console_hoststring: {{ console_hoststring }}
      cm_hoststring: {{ cm_hoststring }}
      cm_port: {{ cm_port }}
      cm_username: {{ cm_username }}
      cm_password: {{ cm_password }}
      hadoop_distro: {{ hadoop_distro }}
      hive_node: {{ hive_node }}
      hive_http_port: {{ hive_http_port }}

platform-testing-cdh-crontab-cdh_blackbox:
  cron.present:
    - identifier: PLATFORM-TESTING-CDH-BLACKBOX
    - user: root
    - name: /bin/systemctl start platform-testing-cdh-blackbox
    - require:
      - pip: platform-testing-cdh-install-requirements-cdh_blackbox
      - file: platform-testing-cdh-blackbox_service

platform-testing-cdh-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload
