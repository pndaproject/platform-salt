{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set platform_testing_version = salt['pillar.get']('platform_testing:release_version', '0.1.1') %}
{% set platform_testing_directory = salt['pillar.get']('platform_testing:release_directory', '/opt/pnda') %}

{% set platform_testing_package = 'platform-testing-cdh' %}

{% set virtual_env_dir = platform_testing_directory + "/" + platform_testing_package + "-" + platform_testing_version + "/venv" %}

{% set console_port = '3001' %}
{% set cm_port = '7180' %}

{% set cm_hoststring = salt['pnda.cloudera_manager_ip']()  %}
{% set console_hoststring = salt['pnda.ip_addresses']('console_backend_data_logger')[0] + ":" + console_port %}
{% set cm_username = pillar['admin_login']['user'] %}
{% set cm_password = pillar['admin_login']['password'] %}

include:
  - python-pip

platform-testing-cdh-dl-and-extract:
  archive.extracted:
    - name: {{ platform_testing_directory }}
    - source: {{ packages_server }}/{{platform_testing_package}}-{{ platform_testing_version }}.tar.gz
    - source_hash: {{ packages_server }}/{{platform_testing_package}}-{{ platform_testing_version }}.tar.gz.sha512.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}

platform-testing-cdh-install_dev_deps:
  pkg.installed:
    - pkgs:
      - libsasl2-dev
      - g++

platform-testing-cdh-create-venv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/requirements.txt
    - require:
      - pip: python-pip-install_python_pip
      - archive: platform-testing-cdh-dl-and-extract

platform-testing-cdh-create-link:
  file.symlink:
    - name: {{ platform_testing_directory }}/{{platform_testing_package}}
    - target: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}

platform-testing-cdh-install-requirements:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/requirements.txt
    - require:
      - virtualenv: platform-testing-cdh-create-venv

platform-testing-cdh-install-requirements-cdh:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/cdh/requirements.txt
    - require:
      - virtualenv: platform-testing-cdh-create-venv

platform-testing-cdh_upstart:
  file.managed:
    - source: salt://platform-testing/templates/platform-testing-cdh.conf.tpl
    - name: /etc/init/platform-testing-cdh.conf
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

platform-testing-cdh-crontab-cdh:
  cron.present:
    - identifier: PLATFORM-TESTING-CDH
    - user: root
    - name: /sbin/start platform-testing-cdh

platform-testing-cdh-install-requirements-cdh_blackbox:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - requirements: {{ platform_testing_directory }}/{{platform_testing_package}}-{{ platform_testing_version }}/plugins/cdh/requirements.txt
    - require:
      - virtualenv: platform-testing-cdh-create-venv

platform-testing-cdh-backbox_upstart:
  file.managed:
    - source: salt://platform-testing/templates/platform-testing-cdh-blackbox.conf.tpl
    - name: /etc/init/platform-testing-cdh-blackbox.conf
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

platform-testing-cdh-crontab-cdh_blackbox:
  cron.present:
    - identifier: PLATFORM-TESTING-CDH-BLACKBOX
    - user: root
    - name: /sbin/start platform-testing-cdh-blackbox
