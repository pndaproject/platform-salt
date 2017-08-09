{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set backend_app_version = pillar['console_backend_data_logger']['release_version'] %}
{% set backend_app_package = 'console-backend-data-logger-' + backend_app_version + '.tar.gz' %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set app_dir = install_dir + '/console-backend-data-logger' %}
{% set app_config_dir = app_dir + '/conf' %}
{% set host_ip = salt['pnda.ip_addresses']('console_backend_data_logger')[0] %}
{% set backend_app_port = salt['pillar.get']('console_backend_data_logger:bind_port', '3001') %}
{% set data_logger_log_file = '/var/log/pnda/console/data-logger.log' %}
{% set data_logger_log_level = 'debug' %}

include:
  - nodejs
  - .utils

# Install nodejs, npm and redis-server
console-backend-install_data_logger_redis:
  pkg.installed:
    - name: {{ pillar['redis-server']['package-name'] }}
    - version: {{ pillar['redis-server']['version'] }}
    - ignore_epoch: True

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

# Create logger config file
console-backend-create_data_logger_logger_conf:
  file.managed:
    - name: {{ app_config_dir }}/logger.json
    - source: salt://console-backend/templates/logger.json.tpl
    - template: jinja
    - defaults:
        log_file: {{ data_logger_log_file }}
        log_level: {{ data_logger_log_level }}

# Install npm dependencies
console-backend-install_backend_data_logger_app_dependencies:
  cmd.run:
    - cwd: {{ app_dir }}
    - name: npm rebuild
    - require:
      - archive: nodejs-dl_and_extract_node
      - cmd: console-backend-install_utils_dependencies

# Create service script from template
console-backend-copy_data_logger_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/init/data-logger.conf
    - source: salt://console-backend/templates/backend_nodejs_app.conf.tpl
{% elif grains['os'] == 'RedHat' %}
    - name: /usr/lib/systemd/system/data-logger.service
    - source: salt://console-backend/templates/backend_nodejs_app.service.tpl
{% endif %}
    - template: jinja
    - defaults:
        no_console_log: True
        host_ip: {{ host_ip }}
        backend_app_port: {{ backend_app_port }}
        app_dir: {{ app_dir }}

{% if grains['os'] == 'RedHat' %}
console-backend-data-logger-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable data-logger; /bin/systemctl enable redis
{%- endif %}

console-backend-redis_start:
  cmd.run:
{% if grains['os'] == 'Ubuntu' %}
    - name: 'service redis-server stop || echo already stopped; service redis-server start'
{% elif grains['os'] == 'RedHat' %}
    - name: 'service redis stop || echo already stopped; service redis start'
{% endif %}

console-backend-data-logger-start_service:
  cmd.run:
    - name: 'service data-logger stop || echo already stopped; service data-logger start'
