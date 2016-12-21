{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set package_repository_version = salt['pillar.get']('package_repository:release_version', '1.0.0') %}
{% set package_repository_directory_name = 'package-repository-' + package_repository_version %}
{% set package_repository_package = 'package-repository-' + package_repository_version + '.tar.gz' %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set package_repository_fs_type = salt['pillar.get']('package_repository:fs_type', '') %}

include:
  - python-pip

package-repository-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ packages_server }}/{{ package_repository_package }}
    - source_hash: {{ packages_server }}/{{ package_repository_package }}.sha512.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ install_dir }}/{{ package_repository_directory_name }} 

package-repository-install_python_deps:
  pip.installed:
    - requirements: {{ install_dir }}/{{ package_repository_directory_name }}/requirements.txt
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip

package-repository-create_package_repository_link:
  file.symlink:
    - name: {{ install_dir }}/package_repository
    - target: {{ install_dir }}/{{ package_repository_directory_name }}

package-repository-copy_configuration:
  file.managed:
    - name: {{ install_dir }}/{{ package_repository_directory_name }}/pr-config.json
    - source: salt://package-repository/templates/pr-config.json.tpl
    - template: jinja

package-repository-copy_upstart:
  file.managed:
    - name: /etc/init/package-repository.conf
    - source: salt://package-repository/templates/package-repository.conf.tpl
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}

package-repository-stop_package_repository:
  cmd.run:
    - name: 'initctl stop package-repository || echo app already stopped'
    - user: root
    - group: root

{% if package_repository_fs_type == 'sshfs' %}
{% include "package-repository/sshfs.sls" %}

{% elif package_repository_fs_type == 'local' %}    
{% set package_repository_fs_location_path = salt['pillar.get']('package_repository:fs_location_path', '/mnt/packages') %}
package-repository-create_fs_location_path:
  file.directory:
    - name: {{ package_repository_fs_location_path }}
    - makedirs: True

{% endif %}

package-repository-start_package_repository:
  cmd.run:
    - name: 'initctl start package-repository'
    - user: root
    - group: root
