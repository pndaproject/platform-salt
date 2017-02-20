{% set mysql_root_password = salt['pillar.get']('mysql:root_pw', 'mysqldefault') %}

include:
  - .connector

{% if grains['os'] == 'Ubuntu' %}
mysql-install-debconf-utils:
  pkg.installed:
    - name: debconf-utils

mysql-setup-mysql:
  debconf.set:
    - name: mysql-server
    - data:
        'mysql-server/root_password': {'type': 'password', 'value': '{{ mysql_root_password }}'}
        'mysql-server/root_password_again': {'type': 'password', 'value': '{{ mysql_root_password }}'}
        'mysql-server/start_on_boot': {'type': 'boolean', 'value': 'true'}
    - require:
      - pkg: mysql-install-debconf-utils
{% endif %}

mysql-install-python-library:
  pkg.installed:
{% if grains['os'] == 'Ubuntu' %}
    - name: python-mysqldb
{% elif grains['os'] == 'RedHat' %}
    - name: MySQL-python
{% endif %}
    - reload_modules: True

mysql-install-mysql-server:
  pkg.installed:
{% if grains['os'] == 'Ubuntu' %}
    - name: mysql-server-5.6
    - require:
      - debconf: mysql-setup-mysql
{% elif grains['os'] == 'RedHat' %}
    - name: mysql-community-server
{% endif %}

mysql-update-mysql-configuration:
  file.replace:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/mysql/my.cnf
{% elif grains['os'] == 'RedHat' %}
    - name: /etc/my.cnf
{% endif %}
    - pattern: bind-address\s*=.*$
    - repl: bind-address      = 0.0.0.0
    - require:
      - pkg: mysql-install-mysql-server

mysql-update-mysql-configuration2:
  file.replace:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/mysql/my.cnf
{% elif grains['os'] == 'RedHat' %}
    - name: /etc/my.cnf
{% endif %}
    - pattern: '# Recommended in standard MySQL setup'
    - repl: skip-name-resolve
    - require:
      - pkg: mysql-install-mysql-server

{% if grains['os'] == 'RedHat' %}
mysql-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable mysqld
{%- endif %}

mysql-mysql-running:
  cmd.run:
{% if grains['os'] == 'Ubuntu' %}
    - name: 'service mysql stop || echo already stopped; service mysql start'
{% elif grains['os'] == 'RedHat' %}
    - name: 'service mysqld stop || echo already stopped; service mysqld start'
{% endif %}

{% if grains['os'] == 'RedHat' %}
mysql_root_password:
  cmd.run:
    - name: mysqladmin --user root password '{{ mysql_root_password|replace("'", "'\"'\"'") }}'
    - unless: mysql --user root --password='{{ mysql_root_password|replace("'", "'\"'\"'") }}' --execute="SELECT 1;"
{% endif %}