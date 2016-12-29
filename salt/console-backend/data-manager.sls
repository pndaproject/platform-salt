{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set backend_app_version = pillar['console_backend_data_manager']['release_version'] %}
{% set backend_app_package = 'console-backend-data-manager-' + backend_app_version + '.tar.gz' %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set app_dir = install_dir + '/console-backend-data-manager' %}
{% set app_config_dir = app_dir + '/conf' %}
{% set pnda_cluster = salt['pnda.cluster_name']() %}
{% set npm_registry = salt['pillar.get']('npm:registry', 'https://registry.npmjs.org/') %}

{% set host_ip = salt['pnda.ip_addresses']('console_backend_data_manager')[0] %}

# get host id of the instance where the console backend is running on the cluster
{% set host_id = '' %}
{% set namenode = [] %}
{% for id, addr_list in salt['mine.get']('G@roles:console_backend and G@pnda_cluster:'+pnda_cluster, 'network.ip_addrs', expr_form='compound').items() %}
{% do namenode.append(id) %}
{% endfor %}
{% set host_id = namenode|join(" ") %}

{% set dm_link = salt['pnda.generate_http_link']('deployment_manager',':5000') %}
{% set data_service_link = salt['pnda.generate_http_link']('data_service',':7000') %}

{% set ldap_ip = salt['pnda.ldap_ip']() %}
{% if ldap_ip == None %}
{%   set ldap_ip = "" %}
{% endif %}

{% set backend_app_port = salt['pillar.get']('console_backend_data_manager:bind_port', '3123') %}


include:
  - nodejs

console-backend-data-manager-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }} 
    - source: {{ packages_server }}/{{ backend_app_package }}
    - source_hash: {{ packages_server }}/{{ backend_app_package }}.sha512.txt
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
        dm_endpoint: {{dm_link}}
        data_service_url: {{data_service_link}}

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
  cmd.run:
    - cwd: {{ install_dir }}/console-backend-utils
    - name: npm config set registry {{ npm_registry }} && npm install --json
    - require:
      - npm: nodejs-update_npm

# Install npm dependencies
console-backend-install_backend_app_dependencies:
  cmd.run:
    - cwd: {{ app_dir }}
    - name: npm config set registry {{ npm_registry }} && npm install --json
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
