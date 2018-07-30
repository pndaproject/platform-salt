{% set knox_version = salt['pillar.get']('knox:release_version', '') %}
{% set knox_authentication = salt['pillar.get']('knox:authentication', '') %}
{% set knox_master_secret = salt['pillar.get']('knox:master_secret', '') %}
{% set knox_zip = 'knox-' + knox_version + '.zip' %}
{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}
{% set namenode_host = salt['pnda.get_hosts_by_hadoop_role']('hdfs_namenode')[0] %}
{% set hive_host = salt['pnda.get_hosts_by_hadoop_role']('hive_server')[0] %}
{% set hive_port = pillar['hadoop_services']['hive_server']['port'] %}
{% set webhdfs_host = salt['pnda.get_hosts_by_hadoop_node']('MGR01')[0] %}
{% set hbase_rest_host = salt['pnda.get_hosts_by_hadoop_node']('MGR01')[0] %}
{% set yarn_rm_hosts = salt['pnda.get_hosts_by_hadoop_role']('yarn_resource_manager') %}
{% set yarn_ha_enabled = (yarn_rm_hosts is not none and yarn_rm_hosts|length>1) %}
{% set mr2_history_server_host = salt['pnda.get_hosts_by_hadoop_role']('yarn_job_histroy_server')[0] %}
{% set spark_history_server_host = salt['pnda.get_hosts_by_hadoop_role']('spark_job_histroy_server')[0] %}
{% set spark_history_server_port =  pillar['hadoop_services']['spark_job_histroy_server']['port'] %} 
{% set spark2_history_server_host = salt['pnda.get_hosts_by_hadoop_role']('spark2_job_histroy_server')[0] %}
{% set ambari_server_host = salt['pnda.get_hosts_for_role']('hadoop_manager')[0] %}
{% set flink_history_server_host = salt['pnda.get_hosts_for_role']("FLINK")[0] %}
{% set flink_history_server_port = pillar['flink']['historyserver_web_port'] %}
# See PNDA-4797 - 'logserver' currently safer role to use than 'elk'
{% set kibana_host = salt['pnda.get_hosts_for_role']('logserver')[0] %}
{% set kafka_manager_host = salt['pnda.get_hosts_for_role']('kafka_manager')[0] %}
{% set pnda_domain = pillar['consul']['data_center'] + '.' + pillar['consul']['domain'] %}
{% set release_directory = pillar['pnda']['homedir'] %}
{% set knox_home_directory = release_directory + '/knox' %}
{% set bin_directory = knox_home_directory + '/bin' %}
{% set conf_directory = knox_home_directory + '/conf' %}
{% set knox_log_directory = '/var/log/pnda/knox' %}
{% set knox_deployment_dir = knox_home_directory + '/data/deployments/' %}
{% set gateway = knox_home_directory + '/data/security/keystores/gateway.jks' %}
{% set opentsdb_port = pillar['opentsdb']['bind_port'] %}
{% set helper_directory = knox_home_directory + '/helper' %}
{% set hadoop_distro = salt['grains.get']('hadoop.distro', 'HDP') %}

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
    - source_hash: {{ mirror_location }}/{{ knox_zip }}.sha1
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

# clean up default topologies
knox-remove-default-topologies:
  file.directory:
    - name: {{ conf_directory }}/topologies/
    - clean: True

knox-create-pnda-topology:
  file.managed:
    - name: {{ conf_directory }}/topologies/pnda.xml
    - source: salt://knox/templates/pnda.xml.tpl
    - template: jinja
    - context:
      hadoop_distro: {{ hadoop_distro }}
      knox_authentication: {{ knox_authentication }}
      namenode_host: {{ namenode_host }}
      webhdfs_host: {{ webhdfs_host }}
      hbase_rest_host: {{ hbase_rest_host }} 
      yarn_rm_hosts: ["{{yarn_rm_hosts|join('", "')|string()}}"]
      hive_host: {{ hive_host }}
      hive_port: {{ hive_port }}
      pnda_domain: {{ pnda_domain }}
      opentsdb_port: {{ opentsdb_port }}
      ha_enabled: {{ yarn_ha_enabled }}
      spark_history_server_host: {{ spark_history_server_host }}
      spark_history_server_port: {{ spark_history_server_port }}
      spark2_history_server_host: {{ spark2_history_server_host }}
      mr2_history_server_host: {{ mr2_history_server_host }}
      ambari_server_host: {{ ambari_server_host }}
      flink_history_server_host: {{ flink_history_server_host }}
      flink_history_server_port: {{ flink_history_server_port }}
    - require:
      - cmd: knox-init-authentication

knox-create-pndaops-topology:
  file.managed:
    - name: {{ conf_directory }}/topologies/pndaops.xml
    - source: salt://knox/templates/pndaops.xml.tpl
    - template: jinja
    - context:
      knox_authentication: {{ knox_authentication }}
      kafka_manager_host: {{ kafka_manager_host }}
      kibana_host: {{ kibana_host }}
    - require:
      - cmd: knox-init-authentication

knox-configure-gateway-site:
  file.managed:
    - name: {{ conf_directory }}/gateway-site.xml
    - source: salt://knox/files/gateway-site.xml

knox-enable_pam_login:
  file.managed:
    - name: /etc/shadow
    - group: knox
    - mode: 040

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
  'dm': 'pnda-deployment-manager/1.0.0',
  'pr':  'pnda-package-repository/1.0.0',
  'tsdb': 'opentsdb/2.3.0',
  'console': 'pnda-console/1.0.0',
  'km': 'kafka-manager/1.3.3',
  'kibana': 'kibana/6.2.1',
  'flinkhistoryui': 'flinkhistoryui/1.4.2'
  } %}

{% if hadoop_distro == 'HDP' %}
  {% do knox_proxy_services.update({'spark2historyui': 'spark2historyui/2.2.0'}) %}
{% endif %}

{% for service_name in knox_proxy_services %}
{% set knox_service_dir = knox_home_directory + '/data/services/' + knox_proxy_services[service_name] %}
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

# knox known issue fixes - jobhistoryui and yarnui rewrite rules overwrites
knox-service_rewrite_yarnui:
  file.managed:
    - name: {{ knox_home_directory }}/data/services/yarnui/2.7.0/rewrite.xml
    - source: salt://knox/files/yarnui_rewrite.xml

knox-service_rewrite_jobhistoryui:
  file.managed:
    - name: {{ knox_home_directory }}/data/services/jobhistoryui/2.7.0/rewrite.xml
    - source: salt://knox/files/jobhistoryui_rewrite.xml

# remove hdfsui 3.0 rewrite files from knox
knox-service_remove_hdfsui30:
  file.absent:
    - name: {{ knox_home_directory }}/data/services/hdfsui/3.0.0

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

