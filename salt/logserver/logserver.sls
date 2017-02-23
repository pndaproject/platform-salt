{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set logstash_version = salt['pillar.get']('logstash:release_version', '1.5.4') %}
{% set logstash_package = 'logstash-' + logstash_version + '.tar.gz' %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set extra_mirror = salt['pillar.get']('extra:mirror', 'https://download.elastic.co/logstash/logstash/') %}
{% set logstash_url = extra_mirror +  'logstash-' +  logstash_version + '.tar.gz' %}

include:
  - java

install-redis_server:
  pkg.installed:
{% if grains['os'] == 'Ubuntu' %}
    - name: redis-server
{% elif grains['os'] == 'RedHat' %}
    - name: redis
{% endif %}

change-bind-address_redis:
  file.replace:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/redis/redis.conf
{% elif grains['os'] == 'RedHat' %}
    - name: /etc/redis.conf
{% endif %}
    - pattern: 'bind 127.0.0.1'
    - repl: 'bind 0.0.0.0'

logserver-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ logstash_url }}
    - source_hash: {{ logstash_url }}.sha1.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ install_dir }}/logstash-1.5.4

logserver-link_release:
  cmd.run:
    - name: ln -f -s {{ install_dir }}/logstash-{{ logstash_version }} {{ install_dir }}/logstash
    - cwd: {{ install_dir }}
    - unless: test -L {{ install_dir }}/logstash

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

logserver-create_log_folder:
  file.directory:
    - name: /var/log/pnda
    - user: root
{% if grains['os'] == 'Ubuntu' %}
    - group: syslog
{% elif grains['os'] == 'RedHat' %}
    - group: root
{% endif %}
    - mode: 777
    - makedirs: True

logserver-copy_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/init/logserver.conf
    - source: salt://logserver/logserver_templates/logstash.conf.tpl
{% elif grains['os'] == 'RedHat' %}
    - name: /usr/lib/systemd/system/logserver.service
    - source: salt://logserver/logserver_templates/logstash.service.tpl
{% endif %}
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}

{% if grains['os'] == 'RedHat' %}
logserver-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable logserver
{%- endif %}

logserver-start_service:
  cmd.run:
    - name: 'service logserver stop || echo already stopped; service logserver start'

logserver-redis-start_service:
  cmd.run:
{% if grains['os'] == 'Ubuntu' %}
    - name: 'service logserver stop || echo already stopped; service logserver start'
{% elif grains['os'] == 'RedHat' %}
    - name: 'service redis stop || echo already stopped; service redis start'
{% endif %}
