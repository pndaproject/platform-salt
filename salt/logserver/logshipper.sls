{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set logstash_version = salt['pillar.get']('logstash:release_version', '1.5.4') %}
{% set logstash_package = 'logstash-' + logstash_version + '.tar.gz' %}
{% set install_dir = pillar['pnda']['homedir'] %}
{% set extra_mirror = salt['pillar.get']('extra:mirror', 'https://download.elastic.co/logstash/logstash/') %}
{% set logstash_url = extra_mirror +  'logstash-' +  logstash_version + '.tar.gz' %}

include:
  - java

{% if grains['os'] == 'RedHat' %}
logshipper-syslog:
  pkg.installed:
    - pkgs:
      - syslog-ng
{% endif %}

logshipper-lbc6:
  pkg.installed:
    - pkgs:
      {% if grains['os'] == 'RedHat' %}
      - glibc-devel
      {% elif grains['os'] == 'Ubuntu' %}
      - libc6-dev
      {% endif %}
      - acl

logshipper-dl-and-extract:
  archive.extracted:
    - name: {{ install_dir }}
    - source: {{ logstash_url }}
    - source_hash: {{ logstash_url }}.sha1.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ install_dir }}/logstash-1.5.4


logshipper-link_release:
  cmd.run:
    - name: ln -f -s {{ install_dir }}/logstash-{{ logstash_version }} {{ install_dir }}/logstash
    - cwd: {{ install_dir }}
    - unless: test -L {{ install_dir }}/logstash

logshipper-copy_configuration:
  file.managed:
    - name: {{ install_dir }}/logstash/shipper.conf
    - source: salt://logserver/logshipper_templates/shipper.conf.tpl
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}

yarn:
  group.present
kafka:
  group.present

logger:
  user.present:
    - groups:
      - yarn
      - root
      - kafka

logshipper-add_salt_permissions:
  cmd.run:
    - name: 'chmod -R 755 /var/log/salt'

logshipper-copy_permission_script:
  file.managed:
    - name: {{ install_dir }}/logstash/open_yarn_log_permissions.sh
    - source: salt://logserver/logshipper_files/open_yarn_log_permissions.sh
    - mode: 755

logshipper-yarnperms-add_crontab_entry:
  cron.present:
    - identifier: YARN-PERMISSIONS
    - name: {{ install_dir }}/logstash/open_yarn_log_permissions.sh
    - user: root
    - minute: '*'

logshipper-create_sincedb_folder:
  file.directory:
    - name: {{ install_dir }}/logstash/sincedb
    - user: root
    {% if grains['os'] == 'RedHat' %}
    - group: root
    {% elif grains['os'] == 'Ubuntu' %}
    - group: syslog
    {% endif %}
    - mode: 777
    - makedirs: True

{% if grains['os'] == 'Ubuntu' %}
logshipper-copy_upstart:
  file.managed:
    - name: /etc/init/logshipper.conf
    - source: salt://logserver/logshipper_templates/logstash.conf.tpl
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}
{% elif grains['os'] == 'RedHat' %}
logshipper-copy_systemd:
  file.managed:
    - name: /usr/lib/systemd/system/logshipper.service
    - source: salt://logserver/logshipper_templates/logstash.service.tpl
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}
logshipper-service_enabled:
  service.running:
    - name: logshipper
    - enable: True
    - reload: True
    - watch:
      - file: logshipper-copy_systemd
{% endif %}

{% if grains['os'] == 'RedHat' %}
logshipper-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload
{%- endif %}

logshipper-stop_service:
  cmd.run:
{% if grains['os'] == 'Ubuntu' %}
    - name: 'initctl stop logshipper || echo logshipper already stopped'
{% elif grains['os'] == 'RedHat' %}
    - name: /bin/systemctl stop logshipper
{% endif %}
    - user: root
    - group: root

logshipper-start_service:
  cmd.run:
{% if grains['os'] == 'Ubuntu' %}
    - name: 'initctl start logshipper'
{% elif grains['os'] == 'RedHat' %}
    - name: /bin/systemctl start logshipper
{% endif %}
    - user: root
    - group: root
