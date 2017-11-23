{% set mysql_root_password = salt['pillar.get']('mysql:root_pw', 'mysqldefault') %}
{% set flavor_cfg = pillar['pnda_flavor']['states'][sls] %}

include:
  - .connector

{% if grains['os'] == 'Ubuntu' %}
mysql-install-debconf-utils:
  pkg.installed:
    - name: {{ pillar['debconf-utils']['package-name'] }}
    - version: {{ pillar['debconf-utils']['version'] }}
    - ignore_epoch: True

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
    - name: {{ pillar['python-mysqldb']['package-name'] }}
    - version: {{ pillar['python-mysqldb']['version'] }}
    - reload_modules: True

mysql-install-mysql-server:
  pkg.installed:
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - debconf: mysql-setup-mysql
{% endif %}
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

{% if grains['os'] == 'Ubuntu' %}
{% if flavor_cfg.data_dir != '/var/lib/mysql' %}
mysql-copy-data:
  cmd.run:
    - name: service mysql stop && cp -R -p /var/lib/mysql {{ flavor_cfg.data_dir }}

mysql-app-armor-rules:
  file.append:
    - text: 'alias /var/lib/mysql/ -> {{ flavor_cfg.data_dir }},'
    - name: /etc/apparmor.d/tunables/alias

mysql-app-armor-reload:
  cmd.run:
    - name: service apparmor reload
{% endif %}
{% endif %}

{% if grains['os'] in ('RedHat', 'CentOS') %}
mysql-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable {{ pillar['mysql-server']['service_name'] }}
{%- endif %}

mysql-mysql-running:
  cmd.run:
    - name: 'service {{ pillar['mysql-server']['service_name'] }} stop || echo already stopped; service {{ pillar['mysql-server']['service_name'] }} start'

{% if grains['os'] in ('RedHat', 'CentOS') %}
mysql_root_password:
  cmd.run:
    - name: mysqladmin --user root password '{{ mysql_root_password|replace("'", "'\"'\"'") }}'
    - unless: mysql --user root --password='{{ mysql_root_password|replace("'", "'\"'\"'") }}' --execute="SELECT 1;"
{% endif %}