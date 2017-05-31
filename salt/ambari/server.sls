ambari-server-user:
  user.present:
    - name: ambari
    - groups:
      - root

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
    - permission: 0644
    - defaults:
        java_version_name: {{ pillar['java']['version_name'] }}

ambari-server-log4j:
  file.managed:
    - name: /etc/ambari-server/conf/log4j.properties
    - source: salt://ambari/files/ambari-server-log4j.properties
    - template: jinja
    - permission: 0644

ambari-server-create_log_dir:
  file.directory:
    - name: /var/log/pnda/ambari/
    - makedirs: True

{% if grains['os'] == 'RedHat' %}
ambari-server-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable ambari-server
{%- endif %}

ambari-server-setup:
  cmd.run:
    - name: 'ambari-server setup -s -j /usr/share/java/{{ pillar['java']['version_name'] }}/; ambari-server setup --jdbc-db=mysql --jdbc-driver=/usr/share/java/mysql-connector-java.jar'

ambari-server-start_service:
  cmd.run:
    - name: 'service ambari-server stop || echo already stopped; service ambari-server start'