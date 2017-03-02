{% set install_dir = pillar['pnda']['homedir'] %}

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set logstash_version = salt['pillar.get']('logstash:release_version', '1.5.4') %}
{% set logstash_package = 'logstash-' + logstash_version + '.tar.gz' %}
{% set logstash_url = mirror_location + logstash_package %}
{% set plugin_pack_url = mirror_location + 'logstash_plugins.tar.gz' %}


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
    - source: {{ logstash_url }}
    - source_hash: {{ logstash_url }}.sha1.txt
    - archive_format: tar
    - tar_options: v
    - if_missing: {{ install_dir }}/logstash-{{ logstash_version }}

logshipper-link_release:
  cmd.run:
    - name: ln -f -s {{ install_dir }}/logstash-{{ logstash_version }} {{ install_dir }}/logstash
    - cwd: {{ install_dir }}
    - unless: test -L {{ install_dir }}/logstash

{% if grains['os'] == 'RedHat' %}
logshipper-journald-plugin:
  cmd.run:
    - name: curl {{ plugin_pack_url }} > {{ install_dir }}/logstash/logstash_plugins.tar.gz; cd {{ install_dir }}/logstash; tar zxf logstash_plugins.tar.gz
{% endif %}

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
