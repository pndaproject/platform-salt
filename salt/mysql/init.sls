{% set mysql_root_password = salt['pillar.get']('mysql:root_pw', 'mysqldefault') %}
{% set flavor_cfg = pillar['pnda_flavor']['states'][sls] %}

include:
  - .connector

mysql-install-python-library:
  pkg.installed:
    - name: {{ pillar['python-mysqldb']['package-name'] }}
    - version: {{ pillar['python-mysqldb']['version'] }}
    - reload_modules: True

mysql-install-mysql-server:
  pkg.installed:
    - name: {{ pillar['mysql-server']['package-name'] }}
    - version: {{ pillar['mysql-server']['version'] }}

mysql-update-mysql-configuration:
  file.replace:
    - name: {{ pillar['mysql-server']['configuration_file'] }}
    - pattern: bind-address\s*=.*$
    - repl: bind-address      = 0.0.0.0
    - require:
      - pkg: mysql-install-mysql-server

mysql-update-mysql-configuration2:
  file.replace:
    - name: {{ pillar['mysql-server']['configuration_file'] }}
    - pattern: '# Recommended in standard MySQL setup'
    - repl: skip-name-resolve
    - require:
      - pkg: mysql-install-mysql-server

mysql-update-mysql-configuration3:
  file.replace:
    - name: {{ pillar['mysql-server']['configuration_file'] }}
    - pattern: datadir\s*=.*$
    - repl: datadir      = {{ flavor_cfg.data_dir }}
    - require:
      - pkg: mysql-install-mysql-server

mysql-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable {{ pillar['mysql-server']['service_name'] }}

mysql-mysql-running:
  cmd.run:
    - name: 'service {{ pillar['mysql-server']['service_name'] }} stop || echo already stopped; service {{ pillar['mysql-server']['service_name'] }} start'

mysql_root_password:
  cmd.run:
    - name: mysqladmin --user root password '{{ mysql_root_password|replace("'", "'\"'\"'") }}'
    - unless: mysql --user root --password='{{ mysql_root_password|replace("'", "'\"'\"'") }}' --execute="SELECT 1;"
