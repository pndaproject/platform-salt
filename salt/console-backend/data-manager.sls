{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set backend_app_version = pillar['console_backend_data_manager']['release_version'] %}
{% set backend_app_package = 'console-backend-data-manager-' + backend_app_version + '.tar.gz' %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set app_dir = install_dir + '/console-backend-data-manager' %}
{% set app_config_dir = app_dir + '/conf' %}
{% set pnda_cluster = salt['pnda.cluster_name']() %}
{% set host_ip = salt['pnda.ip_addresses']('console_backend_data_manager')[0] %}
{% set console_frontend_port = salt['pillar.get']('console_frontend:bind_port', '') %}
# get host names of the instance where the console frontend is running in the cluster
{% set console_frontend_fqdn = salt['mine.get']('roles:console_frontend', 'grains.items', expr_form='grain').values()[0]['fqdn'] %}
{% set console_frontend_hosts = [ console_frontend_fqdn ] %}
{% for id, addr_list in salt['mine.get']('G@roles:console_frontend and G@pnda_cluster:'+pnda_cluster, 'network.ip_addrs', expr_form='compound').items() %}
{%   for addr in addr_list %}
{%     do console_frontend_hosts.append(addr) %}
{%   endfor %}
{% endfor %}
{% set console_frontend_hosts_csv = console_frontend_hosts|join(",") %}
{% set dm_link = salt['pnda.generate_http_link']('deployment_manager',':5000') %}
{% set data_service_link = salt['pnda.generate_http_link']('data_service',':7000') %}
{% set backend_app_port = salt['pillar.get']('console_backend_data_manager:bind_port', '3123') %}
{% set data_manager_log_file = '/var/log/pnda/console/data-manager.log' %}
{% set data_manager_log_level = 'debug' %}
{% set node_version = pillar['nodejs']['version'] %}

include:
  - nodejs
  - .utils

console-backend-data-manager-install_deps_pam_devel:
  pkg.installed:
    - name: {{ pillar['pam-devel']['package-name'] }}
    - version: {{ pillar['pam-devel']['version'] }}
    - ignore_epoch: True
console-backend-data-manager-install_deps_gcc:
  pkg.installed:
    - name: {{ pillar['g++']['package-name'] }}
    - version: {{ pillar['g++']['version'] }}
    - ignore_epoch: True

console-backend-data-manager-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ packages_server }}/{{ backend_app_package }}
    - source_hash: {{ packages_server }}/{{ backend_app_package }}.sha512.txt
    - archive_format: tar
    - tar_options: ''
    - if_missing: {{ install_dir }}/console-backend-data-manager-{{ backend_app_version }}

console-backend-symlink_data_manager_dir:
  file.symlink:
    - name: {{ app_dir }}
    - target: {{ install_dir }}/console-backend-data-manager-{{ backend_app_version }}

# Create data manager config file from template
console-backend-data-manager-config:
  file.managed:
    - name: {{app_config_dir}}/config.js
    - source: salt://console-backend/templates/backend_data_manager_conf.js.tpl
    - template: jinja
    - defaults:
        console_frontend_port: {{ console_frontend_port }}
        console_frontend_hosts_csv: {{ console_frontend_hosts_csv }}
        dm_endpoint: {{dm_link}}
        data_service_url: {{data_service_link}}

# Create logger config file
console-backend-create_data_manager_logger_conf:
  file.managed:
    - name: {{ app_config_dir }}/logger.json
    - source: salt://console-backend/templates/logger.json.tpl
    - template: jinja
    - defaults:
        log_file: {{ data_manager_log_file }}
        log_level: {{ data_manager_log_level }}

# Install npm dependencies
console-backend-install_backend_app_dependencies:
  cmd.run:
    - cwd: {{ app_dir }}
    - name: npm rebuild --nodedir {{ install_dir }}/{{ node_version }}/bin/node > /dev/null
    - require:
      - archive: nodejs-dl_and_extract_node
      - cmd: console-backend-install_utils_dependencies

# Create service script from template
console-backend-copy_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/init/data-manager.conf
    - source: salt://console-backend/templates/backend_nodejs_app.conf.tpl
{% elif grains['os'] in ('RedHat', 'CentOS') %}
    - name: /usr/lib/systemd/system/data-manager.service
    - source: salt://console-backend/templates/backend_nodejs_app.service.tpl
{% endif %}
    - template: jinja
    - defaults:
        host_ip: {{ host_ip }}
        backend_app_port: {{ backend_app_port }}
        app_dir: {{ app_dir }}

{% if grains['os'] in ('RedHat', 'CentOS') %}
console-backend-data-manager-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable data-manager
{%- endif %}

console-backend-data-manager-start_service:
  cmd.run:
    - name: 'service data-manager stop || echo already stopped; service data-manager start'

