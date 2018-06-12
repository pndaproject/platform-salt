{% set knox_version = salt['pillar.get']('knox:release_version', '') %}
{% set knox_authentication = salt['pillar.get']('knox:authentication', '') %}
{% set knox_master_secret = salt['pillar.get']('knox:master_secret', '') %}
{% set knox_zip = 'knox-' + knox_version + '.zip' %}
{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}
{% set namenode_host = salt['pnda.get_hosts_by_hadoop_role']('HDFS', 'NAMENODE')[0] %}
{% set hive_host = salt['pnda.get_hosts_by_hadoop_role']('HIVE', 'HIVE_SERVER')[0] %}
{% set webhdfs_host = salt['pnda.get_hosts_by_hadoop_node']('MGR01')[0] %}
{% set hbase_rest_host = salt['pnda.get_hosts_by_hadoop_node']('MGR01')[0] %}
{% set yarn_rm_host = salt['pnda.get_hosts_by_hadoop_role']('YARN', 'RESOURCEMANAGER')[0] %}
{% set pnda_domain = pillar['consul']['data_center'] + '.' + pillar['consul']['domain'] %}
{% set release_directory = pillar['pnda']['homedir'] %}
{% set knox_home_directory = release_directory + '/knox' %}
{% set bin_directory = knox_home_directory + '/bin' %}
{% set conf_directory = knox_home_directory + '/conf' %}
{% set knox_log_directory = '/var/log/pnda/knox' %}
{% set knox_deployment_dir = knox_home_directory + '/data/deployments/' %}
{% set gateway = knox_home_directory + '/data/security/keystores/gateway.jks' %}

include:
  - java

consul-dep-unzip:
  pkg.installed:
    - pkgs: 
      - {{ pillar['unzip']['package-name'] }}
      - {{ pillar['expect']['package-name'] }}

knox-user-group:
  group.present:
    - name: knox
  user.present:
    - name: knox
    - gid_from_name: True
    - groups:
      - knox

knox-dl-and-extract:
  archive.extracted:
    - name: {{ release_directory }}
    - source: {{ mirror_location }}/{{ knox_zip }}
    - source_hash: {{ mirror_location }}/{{ knox_zip }}.sha
    - user: knox
    - group: knox
    - archive_format: zip
    - if_missing: {{ release_directory }}/knox-{{ knox_version }}

knox-link_release:
  file.symlink:
    - name: {{ knox_home_directory }}
    - target: {{ release_directory }}/knox-{{ knox_version }}

knox-clean-deployments:
  file.directory:
    - name: {{ knox_deployment_dir }}
    - clean: True
    - makedirs: True
    - user: knox
    - group: knox
    - recurse:
      - user
      - group
    - require:
      - archive: knox-dl-and-extract

knox-update-permissions-scripts:
  cmd.run:
    - name: chmod +x {{ bin_directory }}/*.sh
    - user: knox
    - group: knox
    - require:
      - archive: knox-dl-and-extract

knox-create_log_folder:
  file.directory:
    - name: {{ knox_log_directory }}
    - user: knox
    - group: knox
    - mode: 744
    - makedirs: True
    - require:
      - user: knox-user-group
      - group: knox-user-group

{% for log_file in ['shell-log4j.properties', 'gateway-log4j.properties', 'knoxcli-log4j.properties', 'ldap-log4j.properties'] %}
knox-log4j-configuration_{{ log_file }}:
  file.replace:
    - name: {{ conf_directory }}/{{ log_file }}
    - pattern: '^app.log.dir=.*'
    - repl: 'app.log.dir={{ knox_log_directory }}'
    - require:
      - file: knox-create_log_folder
{% endfor %}

{% for sh_file in ['knoxcli.sh', 'ldap.sh', 'gateway.sh'] %}
knox-logsh-configuration_{{ sh_file }}:
  file.replace:
    - name: {{ bin_directory }}/{{ sh_file }}
    - pattern: '^APP_LOG_DIR=.*'
    - repl: 'APP_LOG_DIR="{{ knox_log_directory }}"'
    - require:
      - file: knox-create_log_folder
{% endfor %}

knox-master-secret-script:
  file.managed:
    - name: {{ bin_directory }}/create-secret.sh
    - source: salt://knox/templates/create-secret.sh.tpl
    - user: knox
    - group: knox
    - mode: 755
    - template: jinja
    - context:
      knox_bin_path: {{ bin_directory }}
    - unless: test -f {{ bin_directory }}/create-secret.sh

knox-init-authentication:
  cmd.run:
    - name: {{ bin_directory }}/create-secret.sh {{ knox_master_secret }}
    - user: knox
    - group: knox
    - require:
      - file: knox-master-secret-script

knox-set-configuration:
  file.managed:
    - name: {{ conf_directory }}/topologies/pnda.xml
    - source: salt://knox/templates/pnda.xml.tpl
    - template: jinja
    - context:
      knox_authentication: {{ knox_authentication }}
      namenode_host: {{ namenode_host }}
      webhdfs_host: {{ webhdfs_host }}
      hbase_rest_host: {{ hbase_rest_host }} 
      yarn_rm_host: {{ yarn_rm_host }}
      hive_host: {{ hive_host }}
      pnda_domain: {{ pnda_domain }}
    - require:
      - cmd: knox-init-authentication

{% if knox_authentication == 'pam' %}

knox-enable_pam_login:
  file.managed:
    - name: /etc/shadow
    - group: knox
    - mode: 040

{% endif %}


{% if pillar['knox'] is defined and pillar['knox']['cert'] is defined and pillar['knox']['key'] is defined and pillar['CA'] is defined and pillar['CA']['cert'] is defined %}

knox-create_ssl_cert:
  file.managed:
    - name: {{ conf_directory }}/knox.crt
    - contents_pillar: knox:cert
    - user: knox
    - group: knox
    - mode: 640

knox-create_ssl_key:
  file.managed:
    - name: {{ conf_directory }}/knox.key
    - contents_pillar: knox:key
    - user: knox
    - group: knox
    - mode: 640

knox-create_ssl_ca_cert:
  file.managed:
    - name: {{ conf_directory }}/CA.crt
    - contents_pillar: CA:cert
    - user: knox
    - group: knox
    - mode: 640

knox-export_pkcs12:
  cmd.run:
    - name: openssl pkcs12 -export -in {{ conf_directory }}/knox.crt -inkey {{ conf_directory }}/knox.key -passout pass:{{ knox_master_secret }} > {{ conf_directory }}/server.p12
    - runas: knox
knox-import_pkcs12:
  cmd.run:
    - name: keytool -importkeystore -srcstorepass {{ knox_master_secret }} -deststorepass {{ knox_master_secret }} -srckeystore {{ conf_directory }}/server.p12 -destkeystore {{ gateway }} -srcstoretype pkcs12
    - runas: knox
knox-unset_alias:
  cmd.run:
    - name: keytool -delete -alias "gateway-identity" -keystore {{ gateway }} -storepass {{ knox_master_secret }} || true
    - runas: knox
knox-set_alias:
  cmd.run:
    - name: keytool -changealias -alias "1" -destalias "gateway-identity" -keystore {{ gateway }} -storepass {{ knox_master_secret }}
    - runas: knox
knox-delete_CA:
  cmd.run:
    - name: keytool -noprompt -keystore {{ gateway }} -storepass {{ knox_master_secret }} -alias pnda-CA -delete || true
    - runas: knox
knox-import_CA:
  cmd.run:
    - name: keytool -noprompt -keystore {{ gateway }} -storepass {{ knox_master_secret }} -alias pnda-CA -import -file {{ conf_directory }}/CA.crt
    - runas: knox

{% endif %}


{% set knox_proxy_services = {
  'dm': knox_home_directory + '/data/services/pnda-deployment-manager/1.0.0/',
  'pr': knox_home_directory + '/data/services/pnda-package-repository/1.0.0/'
  } %}

{% for service_name in knox_proxy_services %}
{% set knox_service_dir = knox_proxy_services[service_name] %}
knox-service_dir_{{ service_name }}:
  file.directory:
    - name: {{ knox_service_dir }}
    - makedirs: True
    - require:
      - file: knox-link_release

knox-service_service_{{ service_name }}:
  file.managed:
    - name: {{ knox_service_dir }}/service.xml
    - source: salt://knox/files/{{ service_name }}_service.xml
    - require:
      - file: knox-service_dir_{{ service_name }}

knox-service_rewrite_{{ service_name }}:
  file.managed:
    - name: {{ knox_service_dir }}/rewrite.xml
    - source: salt://knox/files/{{ service_name }}_rewrite.xml
    - require:
      - file: knox-service_dir_{{ service_name }}
{% endfor %}

knox-service-script:
  file.managed:
    - name: /usr/lib/systemd/system/knox.service
    - source: salt://{{ sls }}/templates/knox.service.tpl
    - mode: 0644
    - template: jinja
    - context:
        knox_bin_dir: {{ bin_directory }}
        user: knox
        group: knox
        service: gateway
        service_name: knox

knox-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable knox

knox-start_service:
  cmd.run:
    - name: 'service knox stop || echo already stopped; service knox start'
    - require:
      - cmd: knox-init-authentication
{% for service_name in knox_proxy_services %}
      - file: knox-service_service_{{ service_name }}
      - file: knox-service_rewrite_{{ service_name }}
{% endfor %}

