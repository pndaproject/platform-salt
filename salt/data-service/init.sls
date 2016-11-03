{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set app_version = salt['pillar.get']('data-service:release_version', '1.0.9') %}
{% set app_directory_name = 'data-service-' + app_version %}
{% set app_package = 'data-service-' + app_version + '.tar.gz' %}
{% set pnda_master_dataset_location = pillar['pnda']['master_dataset']['directory'] %}
{% set install_dir = pillar['pnda']['homedir'] %}

include:
  - python-pip

data-service-install_python_deps:
  pip.installed:
    - pkgs:
      - pyhdfs
      - happybase
      - cm_api == 11.0.0
      - tornado
      - tornado-json
      - futures
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip

data-service-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }} 
    - source: {{ packages_server }}/{{ app_package }}
    - source_hash: {{ packages_server }}/{{ app_package }}.sha512.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ install_dir }}/{{ app_directory_name }} 

data-service-create_link:
  file.symlink:
    - name: {{ install_dir }}/data-service
    - target: {{ install_dir }}/{{ app_directory_name }}

data-service-copy_config:
  file.managed:
    - name: {{ install_dir }}/data-service/server.conf
    - source: salt://data-service/templates/server.conf.tpl
    - template: jinja
    - defaults:
        location: {{ pnda_master_dataset_location }}

data-service-copy_upstart:
  file.managed:
    - name: /etc/init/dataservice.conf
    - source: salt://data-service/templates/data-service.conf.tpl
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}

dataservice:
  service.running:
    - enable: True
    - watch:
      - file: data-service-copy_upstart
      - file: data-service-create_link

