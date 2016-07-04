{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set deployment_manager_version = salt['pillar.get']('deployment_manager:release_version', '1.0.0') %}
{% set deployment_manager_directory_name = 'deployment-manager-' + deployment_manager_version %}
{% set deployment_manager_package = 'deployment-manager-' + deployment_manager_version + '.tar.gz' %}
{% set install_dir = '/opt/pnda' %}

include:
  - cdh.cloudera-api
  - python-pip

deployment-manager-install_dev_deps:
  pkg.installed:
    - pkgs:
      - libsasl2-dev
      - g++

deployment-manager-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ packages_server }}/platform/releases/deployment-manager/{{ deployment_manager_package }}
    - source_hash: {{ packages_server }}/platform/releases/deployment-manager/{{ deployment_manager_package }}.sha512.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ install_dir }}/{{ deployment_manager_directory_name }} 

deployment-manager-install_python_deps:
  pip.installed:
    - requirements: {{ install_dir }}/{{ deployment_manager_directory_name }}/requirements.txt
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip

deployment-manager-create_deployment_manager_link:
  file.symlink:
    - name: {{ install_dir }}/deployment_manager
    - target: {{ install_dir }}/{{ deployment_manager_directory_name }}

deployment-manager-copy_configuration:
  file.managed:
    - name: {{ install_dir }}/{{ deployment_manager_directory_name }}/dm-config.json
    - source: salt://deployment-manager/templates/dm-config.json.tpl
    - template: jinja

deployment-manager-gen_key:
  cmd.run:
    - name: 'ssh-keygen -b 2048 -t rsa -f {{ install_dir }}/{{ deployment_manager_directory_name }}/dm.pem -q -N ""'
    - unless: test -f {{ install_dir }}/{{ deployment_manager_directory_name }}/dm.pem

deployment-manager-push_key:
  module.run:
    - name: cp.push
    - path: '{{ install_dir }}/{{ deployment_manager_directory_name }}/dm.pem.pub'

deployment-manager-copy_upstart:
  file.managed:
    - name: /etc/init/deployment-manager.conf
    - source: salt://deployment-manager/templates/deployment-manager.conf.tpl
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}

deployment-manager-stop_deployment_manager:
  cmd.run:
    - name: 'initctl stop deployment-manager || echo app already stopped'
    - user: root
    - group: root

deployment-manager-start_deployment_manager:
  cmd.run:
    - name: 'initctl start deployment-manager'
    - user: root
    - group: root
