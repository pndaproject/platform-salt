{% set package_server = pillar['packages_server']['base_uri'] %}
{% set platformlib_version = salt['pillar.get']('platformlib:release_version', '0.6.8') %}
{% set platformlib_target_directory = salt['pillar.get']('platformlib:target_directory', '/home/cloud-user') %}
{% set platformlib_package = 'platformlibs-' + platformlib_version + '-py2.7.egg' %}
{% set cm_username = pillar['admin_login']['user'] %}
{% set cm_password = pillar['admin_login']['password'] %}
{% set cm_ip = salt['pnda.ip_addresses']('cloudera_manager')[0] %}
{% set platformlibs_config_dir = '/etc/platformlibs' %}
 
platform-libraries-download_egg_file:
  file.managed:
    - name: {{ platformlib_target_directory }}/{{ platformlib_package }}
    - source: {{ package_server }}/platform/releases/platform-libraries/{{ platformlib_package }}
    - source_hash: {{ package_server }}/platform/releases/platform-libraries/{{ platformlib_package }}.sha512.txt

platform-libaries-easy-install:
  cmd.run:
    - name: /opt/cloudera/parcels/Anaconda-4.0.0/bin/python -m easy_install {{ platformlib_target_directory }}/{{ platformlib_package }}

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
