{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set backend_app_version = pillar['console_backend_data_logger']['release_version'] %}
{% set backend_app_package = 'console-backend-data-logger-' + backend_app_version + '.tar.gz' %}
{% set install_dir = '/opt/pnda' %}
{% set app_dir = install_dir + '/console-backend-data-logger' %}
{% set app_config_dir = app_dir + '/conf' %}

{% set host_ip = salt['pnda.ip_addresses']('console_backend')[0] %}

{% set backend_app_port = salt['pillar.get']('console_backend_data_logger:bind_port', '3001') %}

include:
  - nodejs

# Install nodejs, npm and redis-server
console-backend-install_data_logger_redis:
  pkg.installed:
    - pkgs:
      - redis-server

console-backend-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }} 
    - source: {{ packages_server }}/platform/releases/console/{{ backend_app_package }}
    - source_hash: {{ packages_server }}/platform/releases/console/{{ backend_app_package }}.sha512.txt
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
  npm.bootstrap:
    - name: {{ install_dir }}/console-backend-utils
    - require:
      - npm: nodejs-update_npm

# Install npm dependencies
console-backend-install_backend_data_logger_app_dependencies:
  npm.bootstrap:
    - name: {{ app_dir }}
    - require:
      - npm: nodejs-update_npm

# Create upstart script from template
console-backend-copy_data_logger_upstart:
  file.managed:
    - name: /etc/init/data-logger.conf
    - source: salt://console-backend/templates/backend_nodejs_app.conf.tpl
    - template: jinja
    - defaults:
        host_ip: {{ host_ip }}
        backend_app_port: {{ backend_app_port }}
        app_dir: {{ app_dir }}

# Restart the data logger component
data-logger_service:
  service.running:
    - name: data-logger
    - enable: True
    - reload: True
    - watch:
      - file: console-backend-symlink_data_logger_dir
      - file: console-backend-copy_data_logger_upstart
