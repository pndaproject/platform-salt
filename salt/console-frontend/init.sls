{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set console_frontend_version = pillar['console_frontend']['release_version'] %}
{% set console_frontend_package = 'console-frontend-' + console_frontend_version + '.tar.gz' %}
{% set nginx_config_location = '/etc/nginx/sites-enabled' %}
{% set install_dir = '/opt/pnda' %}
{% set console_dir = install_dir + '/console-frontend' %}
{% set console_config_dir = console_dir + '/conf' %}
{% set console_demo_dir = console_dir + '/js/demo' %}
{% set nginx_port = '80' %}
{% set clustername = salt['pnda.cluster_name']() %}
{% set frontend_version = salt['pillar.get']('console_frontend:release_version', 'unknown') %}
{% set data_manager_version = salt['pillar.get']('console_backend_data_manager:release_version', 'unknown') %}
{% set data_manager_port = salt['pillar.get']('console_backend_data_manager:bind_port', '3123') %}

{% set data_manager_host = salt['pnda.ip_addresses']('console_backend')[0] %}

# edge node IP
{% set edge_node_ip = salt['pnda.ip_addresses']('cloudera_edge')[0] %}

# Data logger
{% set data_logger_ip = salt['pnda.ip_addresses']('console_backend')[0] %}
{% set data_logger_port = salt['pillar.get']('console_backend_data_logger:bind_port', '3001') %}

{% set cloudera_manager_ip = salt['pnda.cloudera_manager_ip']() %}

# get Kafka Manager IP
{% set km_ip = salt['pnda.ip_addresses']('tools')[0] %}

# get OpenTSDB IP
{% set opentsdb = salt['pnda.ip_addresses']('opentsdb')[0] %}

# grafana
{% set grafana = salt['pnda.ip_addresses']('grafana')[0] %}

# kibana
{% set kibana = salt['pnda.ip_addresses']('logserver')[0] %}

# Jupyter
{% set jupyter_ip = salt['pnda.ip_addresses']('jupyter')[0] %}

# disable LDAP login on the console if the LDAP server is not present
{% set ldap_ip = salt['pnda.ldap_ip']() %}

include:
  - nodejs

console-frontend-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }} 
    - source: {{ packages_server }}/platform/releases/console/{{ console_frontend_package }}
    - source_hash: {{ packages_server }}/platform/releases/console/{{ console_frontend_package }}.sha512.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ console_dir }}-{{ console_frontend_version }}

console-frontend-create_directory_link:
  file.symlink:
    - name: {{ console_dir }}
    - target: {{ console_dir }}-{{ console_frontend_version }}

# Install npm dependencies
console-frontend-install_app_dependencies:
  npm.bootstrap:
    - name: {{ console_dir }}
    - require:
      - npm: nodejs-update_npm

# Create the config directory if it doesn't exist
console-frontend-create_config_directory:
  file.directory:
    - names: [{{console_config_dir}}]
    - mode: 755
    - makedirs: True

# Create the log directory
console-create_logs_directory:
  file.directory:
    - name: /var/log/pnda/console
    - makedirs: True

# Create the PNDA console json file listing the services to access
console-frontend-create_pnda_console_config:
  file.managed:
    - source: salt://console-frontend/templates/PNDA.json.tpl
    - name: {{console_config_dir}}/PNDA.json
    - template: jinja
    - defaults:
        clustername: {{ clustername }}
        frontend_version: {{ frontend_version }}
        data_manager_version: {{ data_manager_version }}
        data_manager_host: {{ data_manager_host }}
        data_manager_port: {{ data_manager_port }}
        edge_node: {{ edge_node_ip }}
        cloudera_manager_ip: {{ cloudera_manager_ip }}
        kafka_manager_ip: {{ km_ip }}
        opentsdb: {{ opentsdb }}
        grafana: {{ grafana }}
        kibana: {{ kibana }}
        jupyter_ip: {{ jupyter_ip }}
{% if ldap_ip != None %}
        ldap_server_present: True
{% endif %}

# Create a configuration file for nginx and specify where the PNDA console file are
console-frontend-create_pnda_nginx_config:
  file.managed:
    - source: salt://console-frontend/templates/PNDA_nginx.conf.tpl
    - name: {{nginx_config_location}}/PNDA.conf
    - template: jinja
    - defaults:
        console_dir: {{ console_dir }}
        port: {{ nginx_port }}

# Remove default nginx configuration
console-frontend-remove_nginx_default_config:
  file.absent:
    - name: {{nginx_config_location}}/default

# Reload nginx configuration
console-frontend-reload_nginx_config:
  cmd.run:
    - name: sudo nginx -s reload
