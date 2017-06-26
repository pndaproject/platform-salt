{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set deployment_manager_version = salt['pillar.get']('deployment_manager:release_version', '1.0.0') %}
{% set deployment_manager_directory_name = 'deployment-manager-' + deployment_manager_version %}
{% set deployment_manager_package = 'deployment-manager-' + deployment_manager_version + '.tar.gz' %}
{% set install_dir = pillar['pnda']['homedir'] %}

{% set virtual_env_dir = install_dir + "/" + deployment_manager_directory_name + "/venv" %}
{% set pip_index_url = pillar['pip']['index_url'] %}

include:
  - python-pip

{% if grains['os'] == 'RedHat' %}
deployment-manager-install_dev_deps_cyrus:
  pkg.installed:
    - name: {{ pillar['cyrus-sasl-devel']['package-name'] }}
    - version: {{ pillar['cyrus-sasl-devel']['version'] }}
    - ignore_epoch: True

deployment-manager-install_dev_deps_cyrus_gssapi:
  pkg.installed:
    - name: {{ pillar['cyrus-sasl-gssapi']['package-name'] }}
    - version: {{ pillar['cyrus-sasl-gssapi']['version'] }}
    - ignore_epoch: True

deployment-manager-install_dev_deps_cyrus_plain:
  pkg.installed:
    - name: {{ pillar['cyrus-sasl-plain']['package-name'] }}
    - version: {{ pillar['cyrus-sasl-plain']['version'] }}
    - ignore_epoch: True
{% endif %}

deployment-manager-install_dev_deps_libffi:
  pkg.installed:
    - name: {{ pillar['libffi-dev']['package-name'] }}
    - version: {{ pillar['libffi-dev']['version'] }}
    - ignore_epoch: True

deployment-manager-install_dev_deps_libssl:
  pkg.installed:
    - name: {{ pillar['libssl-dev']['package-name'] }}
    - version: {{ pillar['libssl-dev']['version'] }}
    - ignore_epoch: True

deployment-manager-install_dev_deps_sasl:
  pkg.installed:
    - name: {{ pillar['libsasl']['package-name'] }}
    - version: {{ pillar['libsasl']['version'] }}
    - ignore_epoch: True

deployment-manager-install_dev_deps_gcc:
  pkg.installed:
    - name: {{ pillar['g++']['package-name'] }}
    - version: {{ pillar['g++']['version'] }}
    - ignore_epoch: True

deployment-manager-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ packages_server }}/{{ deployment_manager_package }}
    - source_hash: {{ packages_server }}/{{ deployment_manager_package }}.sha512.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ install_dir }}/{{ deployment_manager_directory_name }}

deployment-manager-create-venv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - requirements: {{ install_dir }}/{{ deployment_manager_directory_name }}/requirements.txt
    - python: python2
    - index_url: {{ pip_index_url }}
    - reload_modules: True
    - require:
      - archive: deployment-manager-dl-and-extract

deployment-manager-create_deployment_manager_link:
  file.symlink:
    - name: {{ install_dir }}/deployment_manager
    - target: {{ install_dir }}/{{ deployment_manager_directory_name }}

deployment-manager-copy_configuration:
  file.managed:
    - name: {{ install_dir }}/{{ deployment_manager_directory_name }}/dm-config.json
    - source: salt://deployment-manager/templates/dm-config.json.tpl
    - template: jinja
    - require:
      - archive: deployment-manager-dl-and-extract

deployment-manager-gen_key:
  cmd.run:
    - name: 'ssh-keygen -b 2048 -t rsa -f {{ install_dir }}/{{ deployment_manager_directory_name }}/dm.pem -q -N ""'
    - unless: test -f {{ install_dir }}/{{ deployment_manager_directory_name }}/dm.pem
    - require:
      - archive: deployment-manager-dl-and-extract

deployment-manager-push_key:
  module.run:
    - name: cp.push
    - path: '{{ install_dir }}/{{ deployment_manager_directory_name }}/dm.pem.pub'
    - upload_path: '/keys/dm.pem.pub'
    - require:
      - cmd: deployment-manager-gen_key

deployment-manager-copy_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/init/deployment-manager.conf
    - source: salt://deployment-manager/templates/deployment-manager.conf.tpl
{% elif grains['os'] == 'RedHat' %}
    - name: /usr/lib/systemd/system/deployment-manager.service
    - source: salt://deployment-manager/templates/deployment-manager.service.tpl
{% endif %}    
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}

{% if grains['os'] == 'RedHat' %}
deployment-manager-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable deployment-manager
{%- endif %}

deployment-manager-start_service:
  cmd.run:
    - name: 'service deployment-manager stop || echo already stopped; service deployment-manager start'