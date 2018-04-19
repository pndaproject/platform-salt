{% set install_dir = pillar['pnda']['homedir'] %}

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set logstash_version = pillar['logstash']['version'] %}
{% set logstash_package = 'logstash-' + logstash_version + '.tar.gz' %}
{% set logstash_url = mirror_location + logstash_package %}

include:
  - java

install-redis_server:
  pkg.installed:
    - name: {{ pillar['redis-server']['package-name'] }}
    - version: {{ pillar['redis-server']['version'] }}
    - ignore_epoch: True

change-bind-address_redis:
  file.replace:
    - name: {{ pillar['redis-server']['configuration_filename'] }}
    - pattern: 'bind 127.0.0.1'
    - repl: 'bind 0.0.0.0'

logserver-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ logstash_url }}
    - source_hash: {{ logstash_url }}.sha1
    - archive_format: tar
    - tar_options: ''
    - if_missing: {{ install_dir }}/logstash-{{ logstash_version }}

logserver-link_release:
  file.symlink:
    - name: {{ install_dir }}/logstash
    - target: {{ install_dir }}/logstash-{{ logstash_version }}

logserver-copy_configuration:
  file.managed:
    - name: {{ install_dir }}/logstash/collector.conf
    - source: salt://logserver/logserver_files/collector.conf

logserver-copy_logrotate:
  file.managed:
    - name: /etc/logrotate.d/pnda
    - source: salt://logserver/logserver_files/logrotate.conf

logserver-update-crontab:
  cron.present:
    - identifier: LOGROTATE
    - user: root
    - minute: '*/15'
    - name: /usr/sbin/logrotate /etc/logrotate.conf

logserver-add_crontab_entry1:
  cron.present:
    - identifier: DELETE-YARN-APP-OLD
    - name: /usr/bin/find /var/log/pnda -name 'yarn-application*' -type f -mmin +4320 -delete
    - user: root
    - minute: 15

logserver-add_crontab_entry2:
  cron.present:
    - identifier: DELETE-YARN-APP-ZERO
    - name: /usr/bin/find /var/log/pnda -name 'yarn-application*' -type f -size 0 -delete
    - user: root
    - minute: 15

logserver-add_crontab_entry3:
  cron.present:
    - identifier: DELETE-PLATFORM-APP-OLD
    - name: /usr/bin/find /var/log/pnda -name 'platform_app*' -type f -mmin +4320 -delete
    - user: root
    - minute: 15

logserver-add_crontab_entry4:
  cron.present:
    - identifier: DELETE-PLATFORM-APP-ZERO
    - name: /usr/bin/find /var/log/pnda -name 'platform_app*' -type f -size 0 -delete
    - user: root
    - minute: 15

logserver-create_log_folder:
  file.directory:
    - name: /var/log/pnda
    - user: root
    - group: root
    - mode: 777
    - makedirs: True

logserver-copy_service:
  file.managed:
    - name: /usr/lib/systemd/system/logserver.service
    - source: salt://logserver/logserver_templates/logstash.service.tpl
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}

logserver-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable logserver

logserver-start_service:
  cmd.run:
    - name: 'service logserver stop || echo already stopped; service logserver start'

logserver-redis-start_service:
  cmd.run:
    - name: 'service redis stop || echo already stopped; service redis start'
