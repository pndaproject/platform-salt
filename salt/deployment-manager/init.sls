{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set deployment_manager_version = salt['pillar.get']('deployment_manager:release_version', '1.0.0') %}
{% set deployment_manager_directory_name = 'deployment-manager-' + deployment_manager_version %}
{% set deployment_manager_package = 'deployment-manager-' + deployment_manager_version + '.tar.gz' %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set pip_index_url = salt['pillar.get']('pip:index_url', 'https://pypi.python.org/simple/') %}

{% set virtual_env_dir = install_dir + "/" + deployment_manager_directory_name + "/venv" %}

include:
  - python-pip

deployment-manager-install_dev_deps:
  pkg.installed:
    - pkgs:
{% if grains['os'] == 'Ubuntu' %}
      - libsasl2-dev
      - g++
{% elif grains['os'] == 'RedHat' %}
      - gcc-c++
      - libgsasl-devel
      - cyrus-sasl-devel
{% endif %}

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
    - index_url: {{ pip_index_url }}
    - require:
      - pip: python-pip-install_python_pip
      - archive: deployment-manager-dl-and-extract

deployment-manager-pbr:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - name: pbr==1.10
    - index_url: {{ pip_index_url }}
    - require:
      - virtualenv: deployment-manager-create-venv

deployment-manager-install-requirements:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - requirements: {{ install_dir }}/{{ deployment_manager_directory_name }}/requirements.txt
    - python: python2
    - index_url: {{ pip_index_url }}
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

{% if grains['os'] == 'Ubuntu' %}
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
{% elif grains['os'] == 'RedHat' %}
deployment-manager-copy_systemd:
  file.managed:
    - name: /usr/lib/systemd/system/deployment-manager.service
    - source: salt://deployment-manager/templates/deployment-manager.service.tpl
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: deployment-manager-copy_systemd
deployment-manager-stop_deployment_manager:
  service.dead:
    - name: deployment-manager
    - enable: true
    - watch:
      - file: /usr/lib/systemd/system/deployment-manager.service
{% endif %}

{% if grains['os'] == 'Ubuntu' %}
deployment-manager-start_deployment_manager:
  cmd.run:
    - name: 'initctl start deployment-manager'
    - user: root
    - group: root
{% elif grains['os'] == 'RedHat' %}
deployment-manager-start_deployment_manager:
  service.running:
    - name: deployment-manager
    - enable: true
    - watch:
      - file: /usr/lib/systemd/system/deployment-manager.service
{% endif %}
