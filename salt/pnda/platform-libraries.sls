{% set package_server = pillar['packages_server']['base_uri'] %}
{% set platformlib_version = salt['pillar.get']('platformlib:release_version', '0.6.8') %}
{% set platformlib_target_directory = salt['pillar.get']('platformlib:target_directory', '/home/cloud-user') %}
{% set platformlib_package = 'platformlibs-' + platformlib_version + '-py2.7.egg' %}
{% set cm_username = pillar['admin_login']['user'] %}
{% set cm_password = pillar['admin_login']['password'] %}
{% set cm_ip = salt['pnda.ip_addresses']('hadoop_manager')[0] %}
{% set platformlibs_config_dir = '/etc/platformlibs' %}
{% set pip_index_url = pillar['pip']['index_url'] %}

{% set hadoop_distro = pillar['hadoop.distro'] %}

{% if pillar['hadoop.distro'] == 'HDP' %}
{% set anaconda_home = '/opt/pnda/anaconda' %}
{% else %}
{% set anaconda_home = '/opt/cloudera/parcels/Anaconda' %}
{% endif %}

include:
  - python-pip

platform-libraries-install_cm_api:
  pip.installed:
    - pkgs:
      - cm-api == 14.0.0
    - upgrade: True
    - reload_modules: True
    - index_url: {{ pip_index_url }}
    - require:
      - pip: python-pip-install_python_pip

platform-libraries-create_target_dir:
  file.directory:
    - name: {{ platformlib_target_directory }}
    - makedirs: True

platform-libraries-download_egg_file:
  file.managed:
    - name: {{ platformlib_target_directory }}/{{ platformlib_package }}
    - source: {{ package_server }}/{{ platformlib_package }}
    - source_hash: {{ package_server }}/{{ platformlib_package }}.sha512.txt
    - require:
      - file: platform-libraries-create_target_dir

platform-libraries-link_egg_file:
  file.symlink:
    - name: {{ platformlib_target_directory }}/platformlibs-py2.7.egg
    - target: {{ platformlib_target_directory }}/{{ platformlib_package }}

platform-libaries-easy-install:
  cmd.run:
    - name: {{ anaconda_home }}/bin/python -m easy_install {{ platformlib_target_directory }}/{{ platformlib_package }}

platform-libraries-create-conf-dir:
  file.directory:
    - name: {{ platformlibs_config_dir }}

platform-libraries-copy-conf-file:
  file.managed:
    - source: salt://pnda/templates/platformlibs.ini.tpl
    - name: /etc/platformlibs/platformlibs.ini
    - template: jinja
    - context:
      cm_ip: {{ cm_ip }}
      cm_user: {{ cm_username }}
      cm_pass: {{ cm_password }}
      hadoop_distro: {{ hadoop_distro }}