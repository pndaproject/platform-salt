{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set package_repository_version = salt['pillar.get']('package_repository:release_version', '1.0.0') %}
{% set package_repository_directory_name = 'package-repository-' + package_repository_version %}
{% set package_repository_package = 'package-repository-' + package_repository_version + '.tar.gz' %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set package_repository_fs_type = salt['pillar.get']('package_repository:fs_type', '') %}
{% set pip_index_url = salt['pillar.get']('pip:index_url', 'https://pypi.python.org/simple/') %}

{% set virtual_env_dir = install_dir + "/" + package_repository_directory_name + "/venv" %}

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

package-repository-create-venv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - python: python2
    - index_url: {{ pip_index_url }}
    - require:
      - pip: python-pip-install_python_pip
      - archive: package-repository-dl-and-extract

package-repository-pbr:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - name: pbr==1.10
    - index_url: {{ pip_index_url }}
    - require:
      - virtualenv: package-repository-create-venv

package-repository-install-requirements:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - requirements: {{ install_dir }}/{{ package_repository_directory_name }}/requirements.txt
    - index_url: {{ pip_index_url }}
    - require:
      - pip: package-repository-pbr

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

{% if grains['os'] == 'Ubuntu' %}
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
{% elif grains['os'] == 'RedHat' %}
package-repository-copy_systemd:
  file.managed:
    - name: /usr/lib/systemd/system/package-repository.service
    - source: salt://package-repository/templates/package-repository.service.tpl
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: package-repository-copy_systemd
package-repository-stop_package_repository:
  service.dead:
    - name: package-repository
    - enable: true
    - watch:
      - file: /usr/lib/systemd/system/package-repository.service
{% endif %}

{% if package_repository_fs_type == 'sshfs' %}
{% include "package-repository/sshfs.sls" %}

{% elif package_repository_fs_type == 'local' %}
{% set package_repository_fs_location_path = salt['pillar.get']('package_repository:fs_location_path', '/mnt/packages') %}
package-repository-create_fs_location_path:
  file.directory:
    - name: {{ package_repository_fs_location_path }}
    - makedirs: True

{% endif %}

{% if grains['os'] == 'Ubuntu' %}
package-repository-start_package_repository:
  cmd.run:
    - name: 'initctl start package-repository'
    - user: root
    - group: root
{% elif grains['os'] == 'RedHat' %}
package-repository-start_package_repository:
  service.running:
    - name: package-repository
    - enable: true
    - watch:
      - file: /usr/lib/systemd/system/package-repository.service
{% endif %}
