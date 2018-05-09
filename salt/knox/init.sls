{% set knox_version = salt['pillar.get']('knox:release_version', '') %}
{% set knox_authentication = salt['pillar.get']('knox:authentication', '') %}
{% set knox_master_secret = salt['pillar.get']('knox:master_secret', '') %}
{% set knox_zip = 'knox-' + knox_version + '.zip' %}
{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}
{% set namenode_host = salt['pnda.get_hosts_by_role']('HDFS', 'NAMENODE')[0] %}
{% set oozie_node = salt['pnda.get_hosts_by_role']('OOZIE', 'OOZIE_SERVER')[0] %}
{% set hive_node = salt['pnda.get_hosts_by_role']('HIVE', 'HIVE_SERVER')[0] %}
{% set pnda_domain = pillar['consul']['data_center'] + '.' + pillar['consul']['domain'] %}
{% set release_directory = pillar['pnda']['homedir'] %}
{% set knox_home_directory = release_directory + '/knox' %}
{% set bin_directory = knox_home_directory + '/bin' %}
{% set conf_directory = knox_home_directory + '/conf' %}
{% set knox_log_directory = '/var/log/pnda/knox' %}
{% set knox_deployment_dir = knox_home_directory + '/data/deployments/' %}

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

{% if knox_authentication == 'internal' %}
knox-embedded-ldap-service-script:
  file.managed:
    - name: /usr/lib/systemd/system/knoxldap.service
    - source: salt://{{ sls }}/templates/knox.service.tpl
    - mode: 0644
    - template: jinja
    - context:
        knox_bin_dir: {{ bin_directory }}
        user: knox
        group: knox
        service: ldap
        service_name: "Knox Embedded LDAP"

knox-embedded-ldap-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable knoxldap

knox-embedded-ldap-start_service:
  cmd.run:
    - name: 'service knoxldap stop || echo already stopped; service knoxldap start'

{% endif %}

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
      oozie_node: {{ oozie_node }}
      hive_node: {{ hive_node }}
      pnda_domain: {{ pnda_domain }}
    - require:
      - cmd: knox-init-authentication

{% set knox_dm_dir = knox_home_directory + '/data/services/pnda-deployment-manager/1.0.0/' %}

knox-dm_dir:
  file.directory:
    - name: {{ knox_dm_dir }}
    - makedirs: True
    - require:
      - file: knox-link_release

knox-dm_service:
  file.managed:
    - name: {{ knox_dm_dir }}/service.xml
    - source: salt://knox/files/dm_service.xml
    - require:
      - file: knox-dm_dir

knox-dm_rewrite:
  file.managed:
    - name: {{ knox_dm_dir }}/rewrite.xml
    - source: salt://knox/files/dm_rewrite.xml
    - require:
      - file: knox-dm_dir

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
      - file: knox-dm_service
      - file: knox-dm_rewrite
