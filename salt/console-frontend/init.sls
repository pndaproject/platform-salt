{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set console_frontend_version = pillar['console_frontend']['release_version'] %}
{% set console_frontend_package = 'console-frontend-' + console_frontend_version + '.tar.gz' %}
{% if grains['os'] == 'Ubuntu' %}
{% set nginx_config_location = '/etc/nginx/sites-enabled' %}
{% elif grains['os'] == 'RedHat' %}
{% set nginx_config_location = '/etc/nginx/conf.d' %}
{% endif %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set console_dir = install_dir + '/console-frontend' %}
{% set console_config_dir = console_dir + '/conf' %}
{% set console_demo_dir = console_dir + '/js/demo' %}
{% set nginx_port = salt['pillar.get']('console_frontend:bind_port', '80') %}
{% set clustername = salt['pnda.cluster_name']() %}
{% set frontend_version = salt['pillar.get']('console_frontend:release_version', 'unknown') %}
{% set km_port = salt['pillar.get']('kafkamanager:bind_port', 10900) %}
{% set hadoop_distro = pillar['hadoop.distro'] %}

{% set data_manager_host = salt['pnda.ip_addresses']('console_backend_data_manager')[0] %}
{% set data_manager_port = salt['pillar.get']('console_backend_data_manager:bind_port', '3123') %}
{% set data_manager_version = salt['pillar.get']('console_backend_data_manager:release_version', 'unknown') %}

# edge node IP
{% set edge_nodes = salt['pnda.ip_addresses']('hadoop_edge') %}
{%- if edge_nodes is not none and edge_nodes|length > 0 -%}
    {%- set edge_node_ip = edge_nodes[0] -%}
{%- else -%}
    {%- set edge_node_ip = '' -%}
{%- endif -%}

{%- if pillar['hadoop.distro'] == 'CDH' -%}
{% set cm_port = ':7180' %}
{%- else -%}
{% set cm_port = ':8080' %}
{%- endif -%}

# Set links
{% set hadoop_manager_link = salt['pnda.generate_http_link']('hadoop_manager', cm_port) %}
{% set km_link = salt['pnda.generate_http_link']('kafka_manager',':'+km_port|string+'/clusters/'+clustername) %}
{% set opentsdb_link = salt['pnda.generate_http_link']('opentsdb',':4242') %}
{% set grafana_link = salt['pnda.generate_http_link']('grafana',':3000') %}
{% set kibana_link = salt['pnda.generate_http_link']('logserver',':5601') %}
{% set jupyter_link = salt['pnda.generate_http_link']('jupyter',':8000') %}

# disable LDAP login on the console if the LDAP server is not present
{% set ldap_ip = salt['pnda.ldap_ip']() %}

include:
  - nodejs

console-frontend-dl-and-extract:
  archive.extracted:
    - name: {{ console_dir }}-{{ console_frontend_version }}
    - source: {{ packages_server }}/{{ console_frontend_package }}
    - source_hash: {{ packages_server }}/{{ console_frontend_package }}.sha512.txt
    - user: root
{% if grains['os'] == 'Ubuntu' %}
    - group: www-data
{% elif grains['os'] == 'RedHat' %}
    - group: nginx
{% endif %}
    - archive_format: tar
    - tar_options: --strip-components=1
    - if_missing: {{ console_dir }}-{{ console_frontend_version }}

console-frontend-create_directory_link:
  file.symlink:
    - name: {{ console_dir }}
    - target: {{ console_dir }}-{{ console_frontend_version }}

# Install npm dependencies
console-frontend-install_app_dependencies:
  cmd.run:
    - cwd: {{ console_dir }}
    - name: npm rebuild
    - require:
      - archive: nodejs-dl_and_extract_node

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
        hadoop_distro: {{ hadoop_distro }}
        clustername: {{ clustername }}
        frontend_version: {{ frontend_version }}
        data_manager_version: {{ data_manager_version }}
        data_manager_host: {{ data_manager_host }}
        data_manager_port: {{ data_manager_port }}
        edge_node: {{ edge_node_ip }}
        hadoop_manager_link: "{{ hadoop_manager_link }}"
        kafka_manager_link: "{{ km_link }}"
        opentsdb_link: "{{ opentsdb_link }}"
        grafana_link: "{{ grafana_link }}"
        kibana_link: "{{ kibana_link }}"
        jupyter_link: "{{ jupyter_link }}"
{% if ldap_ip != None %}
        ldap_server_present: True
{% endif %}

# Create a configuration file for nginx and specify where the PNDA console file are
console-frontend-create_pnda_nginx_config:
  file.managed:
    - source: salt://console-frontend/templates/PNDA_nginx.conf.tpl
    - name: {{ nginx_config_location }}/PNDA.conf
    - template: jinja
    - defaults:
        console_dir: {{ console_dir }}
        port: {{ nginx_port }}

# Remove default nginx configuration
console-frontend-remove_nginx_default_config:
  file.absent:
    - name: {{nginx_config_location}}/default

{% if grains['os'] == 'RedHat' %}
console-frontend-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable nginx
{%- endif %}

console-frontend-start_service:
  cmd.run:
    - name: 'service nginx stop || echo already stopped; service nginx start'

