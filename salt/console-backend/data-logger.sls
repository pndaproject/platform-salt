{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set backend_app_version = pillar['console_backend_data_logger']['release_version'] %}
{% set backend_app_package = 'console-backend-data-logger-' + backend_app_version + '.tar.gz' %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set app_dir = install_dir + '/console-backend-data-logger' %}
{% set app_config_dir = app_dir + '/conf' %}
{% set npm_registry = salt['pillar.get']('npm:registry', 'https://registry.npmjs.org/') %}

{% set host_ip = salt['pnda.ip_addresses']('console_backend_data_logger')[0] %}

{% set backend_app_port = salt['pillar.get']('console_backend_data_logger:bind_port', '3001') %}

include:
  - nodejs

# Install nodejs, npm and redis-server
console-backend-install_data_logger_redis:
  pkg.installed:
    - pkgs:
{% if grains['os'] == 'Ubuntu' %}
      - redis-server
{% elif grains['os'] == 'RedHat' %}
      - redis
{% endif %}

console-backend-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ packages_server }}/{{ backend_app_package }}
    - source_hash: {{ packages_server }}/{{ backend_app_package }}.sha512.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ install_dir }}/console-backend-data-logger-{{ backend_app_version }}

console-backend-symlink_data_logger_dir:
  file.symlink:
    - name: {{ app_dir }}
    - target: {{ install_dir }}/console-backend-data-logger-{{ backend_app_version }}

# Move utils directory from the archive one directory up
console-backend-symlink_data_logger_utils_dir:
  file.symlink:
    - name: {{ install_dir }}/console-backend-utils
    - target: {{ app_dir }}/console-backend-utils

# Create utils config file
console-backend-create_data_logger_util_conf:
  file.managed:
    - name: {{ install_dir }}/console-backend-utils/conf/config.json
    - source: salt://console-backend/templates/backend_utils_config.json.tpl
    - template: jinja
    - defaults:
        log_file: /var/log/pnda/console/platform-console-logs.log

# Install npm dependencies for utils
console-backend-install_data_logger_utils_dependencies:
  cmd.run:
    - cwd: {{ install_dir }}/console-backend-utils
    - name: npm config set registry {{ npm_registry }} && npm install --json
    - require:
      - pkg: nodejs-install_useful_packages

# Install npm dependencies
console-backend-install_backend_data_logger_app_dependencies:
  cmd.run:
    - cwd: {{ app_dir }}
    - name: npm config set registry {{ npm_registry }} && npm install --json
    - require:
      - pkg: nodejs-install_useful_packages

{% if grains['os'] == 'Ubuntu' %}
# Create upstart script from template
console-backend-copy_data_logger_upstart:
  file.managed:
    - name: /etc/init/data-logger.conf
    - source: salt://console-backend/templates/backend_nodejs_app.conf.tpl
    - template: jinja
    - defaults:
        no_console_log: True
        host_ip: {{ host_ip }}
        backend_app_port: {{ backend_app_port }}
        app_dir: {{ app_dir }}
{% elif grains['os'] == 'RedHat' %}
console-backend-systemd:
  file.managed:
    - name: /usr/lib/systemd/system/data-logger.service
    - source: salt://console-backend/templates/backend_nodejs_app.service.tpl
    - template: jinja
    - defaults:
        no_console_log: True
        host_ip: {{ host_ip }}
        backend_app_port: {{ backend_app_port }}
        app_dir: {{ app_dir }}
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: console-backend-systemd
{% endif %}

# Restart the data logger component
data-logger_service:
  service.running:
    - name: data-logger
    - enable: True
    - reload: True
    - watch:
      - file: console-backend-symlink_data_logger_dir
{% if grains['os'] == 'Ubuntu' %}
      - file: console-backend-copy_data_logger_upstart
{% elif grains['os'] == 'RedHat' %}
      - file: console-backend-systemd
{% endif %}

{% if grains['os'] == 'Ubuntu' %}
console-backend-redis_start:
  cmd.run:
    - name: 'service redis-server restart'
    - user: root
    - group: root
{% elif grains['os'] == 'RedHat' %}
console-backend-redis_start:
    service.running:
      - name: redis
      - enable: True
{% endif %}
