{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set package_repository_version = salt['pillar.get']('package_repository:release_version', '1.0.0') %}
{% set package_repository_directory_name = 'package-repository-' + package_repository_version %}
{% set package_repository_package = 'package-repository-' + package_repository_version + '.tar.gz' %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set package_repository_fs_type = salt['pillar.get']('package_repository:fs_type', '') %}

{% set virtual_env_dir = install_dir + "/" + package_repository_directory_name + "/venv" %}
{% set pip_index_url = pillar['pip']['index_url'] %}

include:
  - python-pip

package-repository-install_dev_deps:
  pkg.installed:
    - name: {{ pillar['g++']['package-name'] }}
    - version: {{ pillar['g++']['version'] }}
    - ignore_epoch: True 

package-repository-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ packages_server }}/{{ package_repository_package }}
    - source_hash: {{ packages_server }}/{{ package_repository_package }}.sha512.txt
    - archive_format: tar
    - tar_options: ''
    - if_missing: {{ install_dir }}/{{ package_repository_directory_name }}

package-repository-create-venv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - requirements: {{ install_dir }}/{{ package_repository_directory_name }}/requirements.txt
    - python: python2
    - index_url: {{ pip_index_url }}
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip
      - archive: package-repository-dl-and-extract

package-repository-create_package_repository_link:
  file.symlink:
    - name: {{ install_dir }}/package_repository
    - target: {{ install_dir }}/{{ package_repository_directory_name }}

package-repository-copy_configuration:
  file.managed:
    - name: {{ install_dir }}/{{ package_repository_directory_name }}/pr-config.json
    - source: salt://package-repository/templates/pr-config.json.tpl
    - template: jinja
    - require:
      - archive: package-repository-dl-and-extract

package-repository-copy_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/init/package-repository.conf
    - source: salt://package-repository/templates/package-repository.conf.tpl
{% elif grains['os'] in ('RedHat', 'CentOS') %}
    - name: /usr/lib/systemd/system/package-repository.service
    - source: salt://package-repository/templates/package-repository.service.tpl
{% endif %}    
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}

{% if package_repository_fs_type == 'sshfs' %}
{% include "package-repository/sshfs.sls" %}

{% elif package_repository_fs_type == 'local' %}
{% set package_repository_fs_location_path = salt['pillar.get']('package_repository:fs_location_path', '/mnt/packages') %}
package-repository-create_fs_location_path:
  file.directory:
    - name: {{ package_repository_fs_location_path }}
    - makedirs: True

{% endif %}

{% if grains['os'] in ('RedHat', 'CentOS') %}
package-repository-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable package-repository
{%- endif %}

package-repository-start_service:
  cmd.run:
    - name: 'service package-repository stop || echo already stopped; service package-repository start'
