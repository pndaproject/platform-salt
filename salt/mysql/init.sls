{% set mysql_root_password = salt['pillar.get']('mysql:root_pw', 'mysqldefault') %}

include:
  - .connector
  
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

mysql-install-python-library:
  pkg.installed:
    - name: python-mysqldb
    - reload_modules: True

mysql-install-mysql-server:
  pkg.installed:
    - name: mysql-server-5.6
    - require:
      - debconf: mysql-setup-mysql

mysql-update-mysql-configuration:
  file.replace:
    - name: /etc/mysql/my.cnf
    - pattern: bind-address\s*=.*$
    - repl: bind-address      = 0.0.0.0
    - require:
      - pkg: mysql-install-mysql-server

mysql-mysql-running:
  service.running:
    - name: mysql
    - watch:
      - pkg: mysql-install-mysql-server
      - file: /etc/mysql/my.cnf
