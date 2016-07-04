{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set backend_app_version = pillar['console_backend_data_manager']['release_version'] %}
{% set backend_app_package = 'console-backend-data-manager-' + backend_app_version + '.tar.gz' %}
{% set install_dir = '/opt/pnda' %}
{% set app_dir = install_dir + '/console-backend-data-manager' %}
{% set app_config_dir = app_dir + '/conf' %}
{% set pnda_cluster = salt['pnda.cluster_name']() %}

{% set host_ip = salt['pnda.ip_addresses']('console_backend')[0] %}

# get host id of the instance where the console backend is running on the cluster
{% set host_id = '' %}
{% set namenode = [] %}
{% for id, addr_list in salt['mine.get']('G@roles:console_backend and G@pnda_cluster:'+pnda_cluster, 'network.ip_addrs', expr_form='compound').items() %}
{% do namenode.append(id) %}
{% endfor %}
{% set host_id = namenode|join(" ") %}

{% set dm_ip = salt['pnda.ip_addresses']('deployment_manager')[0] %}

{% set ldap_ip = salt['pnda.ldap_ip']() %}
{% if ldap_ip == None %}
{%   set ldap_ip = "" %}
{% endif %}

{% set backend_app_port = salt['pillar.get']('console_backend_data_manager:bind_port', '3123') %}

{% set data_service_ip = salt['pnda.ip_addresses']('data_service')[0] %}

include:
  - nodejs

console-backend-data-manager-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }} 
    - source: {{ packages_server }}/platform/releases/console/{{ backend_app_package }}
    - source_hash: {{ packages_server }}/platform/releases/console/{{ backend_app_package }}.sha512.txt
    - archive_format: tar
    - tar_options: v
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
        nodename: {{ host_id }}
        dm_endpoint: http://{{dm_ip}}:5000
        data_service_url: http://{{data_service_ip}}:7000

# Create LDAP config file from template
console-backend-ldap-config:
  file.managed:
    - name: {{app_config_dir}}/ldap_config.js
    - source: salt://console-backend/templates/backend_ldap_conf.js.tpl
    - template: jinja
    - defaults:
        ldap_endpoint: {{ ldap_ip }}

# Move utils directory from the archive one directory up
console-backend-symlink_utils_dir:
  file.symlink:
    - name: {{ install_dir }}/console-backend-utils
    - target: {{ app_dir }}/console-backend-utils

# Create utils config file
console-backend-create_data_manager_util_conf:
  file.managed:
    - name: {{ install_dir }}/console-backend-utils/conf/config.json
    - source: salt://console-backend/templates/backend_utils_config.json.tpl
    - template: jinja
    - defaults:
        log_file: /var/log/pnda/console/platform-console-logs.log

# Install npm dependencies for utils
console-backend-install_utils_dependencies:
  npm.bootstrap:
    - name: {{ install_dir }}/console-backend-utils
    - require:
      - npm: nodejs-update_npm

# Install npm dependencies
console-backend-install_backend_app_dependencies:
  npm.bootstrap:
    - name: {{ app_dir }}
    - require:
      - npm: nodejs-update_npm

# Create upstart script from template
console-backend-copy_upstart:
  file.managed:
    - name: /etc/init/data-manager.conf
    - source: salt://console-backend/templates/backend_nodejs_app.conf.tpl
    - template: jinja
    - defaults:
        host_ip: {{ host_ip }}
        backend_app_port: {{ backend_app_port }}
        app_dir: {{ app_dir }}

# Restart the backend app if necessary
data-manager:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: {{app_config_dir}}/config.js
      - file: {{app_config_dir}}/ldap_config.js
      - file: console-backend-copy_upstart
