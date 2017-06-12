{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set app_version = salt['pillar.get']('data-service:release_version', '1.0.9') %}
{% set app_directory_name = 'data-service-' + app_version %}
{% set app_package = 'data-service-' + app_version + '.tar.gz' %}
{% set pnda_master_dataset_location = pillar['pnda']['master_dataset']['directory'] %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set hadoop_distro = pillar['hadoop.distro'] %}

{% set virtual_env_dir = install_dir + "/" + app_directory_name + "/venv" %}
{% set pip_index_url = pillar['pip']['index_url'] %}

include:
  - python-pip

data-service-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ packages_server }}/{{ app_package }}
    - source_hash: {{ packages_server }}/{{ app_package }}.sha512.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ install_dir }}/{{ app_directory_name }}

data-service-create-venv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - requirements: salt://data-service/files/requirements.txt
    - python: python2
    - index_url: {{ pip_index_url }}
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip
      - archive: data-service-dl-and-extract

data-service-create_link:
  file.symlink:
    - name: {{ install_dir }}/data-service
    - target: {{ install_dir }}/{{ app_directory_name }}
    - require:
      - archive: data-service-dl-and-extract

data-service-copy_config:
  file.managed:
    - name: {{ install_dir }}/data-service/server.conf
    - source: salt://data-service/templates/server.conf.tpl
    - template: jinja
    - defaults:
        location: {{ pnda_master_dataset_location }}
        hadoop_distro: {{ hadoop_distro }}
    - require:
      - archive: data-service-dl-and-extract

data-service-copy_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/init/dataservice.conf
    - source: salt://data-service/templates/data-service.conf.tpl
{% elif grains['os'] == 'RedHat' %}
    - name: /usr/lib/systemd/system/dataservice.service
    - source: salt://data-service/templates/data-service.service.tpl
{%- endif %}
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}

{% if grains['os'] == 'RedHat' %}
data-service-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable dataservice
{%- endif %}

data-service-start_service:
  cmd.run:
    - name: 'service dataservice stop || echo already stopped; service dataservice start'

