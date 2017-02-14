{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set logstash_version = salt['pillar.get']('logstash:release_version', '1.5.4') %}
{% set logstash_package = 'logstash-' + logstash_version + '.tar.gz' %}
{% set install_dir = pillar['pnda']['homedir'] %}

include:
  - java

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
    - source: https://download.elastic.co/logstash/logstash/logstash-1.5.4.tar.gz
    - source_hash: https://download.elastic.co/logstash/logstash/logstash-1.5.4.tar.gz.sha1.txt
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
    - mode: 777
    - makedirs: True

logshipper-copy_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/init/logshipper.conf
    - source: salt://logserver/logshipper_templates/logstash.conf.tpl
{% elif grains['os'] == 'RedHat' %}
    - name: /usr/lib/systemd/system/logshipper.service
    - source: salt://logserver/logshipper_templates/logstash.service.tpl
{% endif %}
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}

{% if grains['os'] == 'RedHat' %}
logshipper-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable logshipper
{%- endif %}

logshipper-start_service:
  cmd.run:
    - name: 'service logshipper stop || echo already stopped; service logshipper start'
