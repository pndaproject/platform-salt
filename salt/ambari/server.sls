{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}
{% set jdbc_package = 'je-5.0.73.jar' %}
{%- set cm_host = salt['pnda.ip_addresses']('hadoop_manager')[0] -%}
{% set cmdb_user = pillar['hadoop_manager']['cmdb']['user'] %}
{% set cmdb_database = pillar['hadoop_manager']['cmdb']['database'] %}
{% set cmdb_password = pillar['hadoop_manager']['cmdb']['password'] %}
{%- set cmdb_host = salt['pnda.ip_addresses']('oozie_database')[0] -%}
{% set mysql_root_password = salt['pillar.get']('mysql:root_pw', 'mysqldefault') %}

include:
  - java
  - mysql.connector
  - mysql

ambari-server-user:
  user.present:
    - name: ambari
    - groups:
      - root

ambari-server-init_mysql_user_permissions:
  mysql_user.present:
    - host: {{ cmdb_host }}
    - host: localhost
    - host: '%'
    - name: {{ cmdb_user }}
    - password: {{ cmdb_password }}
    - connection_host: {{ cmdb_host }}
    - connection_user: root
    - connection_pass: {{ mysql_root_password }}
  mysql_grants.present:
    - grant: all privileges
    - database: '*.*'
    - user: {{ cmdb_user }}
    - host: {{ cmdb_host }}
    - host: localhost
    - host: '%'
    - connection_host: {{ cmdb_host }}
    - connection_user: root
    - connection_pass: {{ mysql_root_password }}
  mysql_database.present:
    - name: {{ cmdb_database }}
    - connection_host: {{ cmdb_host }}
    - connection_user: root
    - connection_pass: {{ mysql_root_password }}
  cmd.run:
    - name: mysql -h {{ cmdb_host }} -uroot -p{{ mysql_root_password }} {{ cmdb_database }} < /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql
    - require:
      - pkg: ambari-server-pkg

ambari-server-pkg:
  pkg.installed:
    - name: {{ pillar['ambari-server']['package-name'] }}
    - version: {{ pillar['ambari-server']['version'] }}
    - ignore_epoch: True

ambari-server-properties:
  file.managed:
    - name: /etc/ambari-server/conf/ambari.properties
    - source: salt://ambari/templates/ambari-server.properties.tpl
    - template: jinja
    - mode: 0644
    - defaults:
      java_version_name: {{ pillar['java']['version_name'] }}

ambari-server-log4j:
  file.managed:
    - name: /etc/ambari-server/conf/log4j.properties
    - source: salt://ambari/files/ambari-server-log4j.properties
    - template: jinja
    - mode: 0644

ambari-server-create_log_dir:
  file.directory:
    - name: /var/log/pnda/ambari/
    - makedirs: True

ambari-server-create_jdbc_dir:
  file.directory:
    - name: /opt/pnda/jdbc-driver
    - makedirs: True

ambari-server-jdbc-dl:
  file.managed:
    - name: /opt/pnda/jdbc-driver/{{ jdbc_package }}
    - source: {{ mirror_location }}/{{ jdbc_package }}
    - source_hash: {{ mirror_location }}/{{ jdbc_package }}.sha512.txt

{% if grains['os'] in ('RedHat', 'CentOS') %}
ambari-server-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable ambari-server
{%- endif %}

ambari-server-setup_init:
  cmd.run:
    - name: 'ambari-server setup -s -j /usr/share/java/{{ pillar['java']['version_name'] }}/;'

ambari-server-properties_delete_pool:
  file.line:
    - name: /etc/ambari-server/conf/ambari.properties
    - mode: delete
    - match: "server.jdbc.connection-pool=internal"
    - content: ""

ambari-server-properties_delete_database:
  file.line:
    - name: /etc/ambari-server/conf/ambari.properties
    - mode: delete
    - match: "server.jdbc.database_name=ambari"
    - content: ""

ambari-server-properties_update_pool:
  file.line:
    - name: /etc/ambari-server/conf/ambari.properties
    - mode: delete
    - match: "server.jdbc.database=postgres"
    - content: ""

ambari-server-password:
  file.managed:
    - name: /etc/ambari-server/conf/password.dat
    - mode: 0644
    - contents:
      - {{ cmdb_password }}

ambari-server-properties_update_config:
  file.append:
    - name: /etc/ambari-server/conf/ambari.properties
    - text:
      - "server.jdbc.driver.path=/usr/share/java/mysql-connector-java.jar"
      - "server.persistence.type=remote"
      - "server.jdbc.database=mysql"
      - "server.jdbc.connection-pool.acquisition-size=5"
      - "server.jdbc.connection-pool.idle-test-interval=7200"
      - "server.jdbc.connection-pool.max-age=0"
      - "server.jdbc.connection-pool.max-idle-time=14400"
      - "server.jdbc.connection-pool.max-idle-time-excess=0"
      - "server.jdbc.database_name={{ cmdb_database }}"
      - "server.jdbc.driver=com.mysql.jdbc.Driver"
      - "server.jdbc.hostname={{ cmdb_host }}"
      - "server.jdbc.port=3306"
      - "server.jdbc.rca.driver=com.mysql.jdbc.Driver"
      - "server.jdbc.rca.url=jdbc:mysql://{{ cmdb_host }}:3306/{{ cmdb_database }}"
      - "server.jdbc.rca.user.name={{ cmdb_user }}"
      - "server.jdbc.rca.user.passwd=/etc/ambari-server/conf/password.dat"
      - "server.jdbc.url=jdbc:mysql://{{ cmdb_host }}:3306/{{ cmdb_database }}"
      - "server.jdbc.user.name={{ cmdb_user }}"

ambari-server-setup_mysql:
  cmd.run:
    - name: 'ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar; ambari-server setup --jdbc-db=bdb --jdbc-driver=/opt/pnda/jdbc-driver/{{ jdbc_package }}'

{% if grains['os'] == 'Ubuntu' %}
# See AMBARI-22532, and remove this work around when that is resolved
ambari-server-patchfix1:
  file.replace:
    - name: /usr/lib/ambari-server/lib/resource_management/core/providers/package/apt.py
    - pattern: '^.*if repo_id in package\[2\]:'
    - repl: '          if urllib.unquote(repo_id).decode("utf-8") in urllib.unquote(package[2]).decode("utf-8"):'

ambari-server-patchfix2:
  file.replace:
    - name: /usr/lib/ambari-server/lib/resource_management/core/providers/package/apt.py
    - pattern: 'import subprocess'
    - repl: |
        import subprocess
        import urllib
{% endif %}

ambari-server-start_service:
  cmd.run:
    - name: 'service ambari-server stop || echo already stopped; service ambari-server start'
