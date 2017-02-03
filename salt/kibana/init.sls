{% set kibana_version = salt['pillar.get']('kibana:version', '4.1.6-linux-x64') %}
{% set kibana_directory = salt['pillar.get']('kibana:directory', '/opt/pnda') %}
{% set extra_mirror = salt['pillar.get']('extra:mirror', 'https://download.elastic.co/kibana/kibana/') %}
{% set kibana_url = extra_mirror +  'kibana-' +  kibana_version + '.tar.gz' %}

#TODO: manage once multiple elasticsearch instances

kibana-kibana:
  group.present:
    - name: kibana
  user.present:
    - name: kibana
    - gid_from_name: True
    - groups:
      - kibana

kibana-create_kibana_dir:
  file.directory:
    - name: {{kibana_directory}}
    - user: root
    - group: root
    - dir_mode: 777
    - makedirs: True

kibana-dl_and_extract_kibana:
  archive.extracted:
    - name: {{kibana_directory}}
    - source: {{ kibana_url }}
    - source_hash: {{ kibana_url }}.sha1.txt
    - archive_format: tar
    - if_missing: {{kibana_directory}}/kibana-{{kibana_version }}

kibana-copy_configuration_kibana:
  file.managed:
    - name: {{kibana_directory}}/kibana-{{ kibana_version }}/config/kibana.yml
    - source: salt://kibana/files/kibana.yml
    - user: kibana
    - group: kibana

{% if grains['os'] == 'Ubuntu' %}
kibana-copy_kibana_upstart:
  file.managed:
    - source: salt://kibana/templates/kibana.init.conf.tpl
    - name: /etc/init/kibana.conf
    - mode: 644
    - template: jinja
    - context:
      installdir: {{kibana_directory}}/kibana-{{ kibana_version }}
{% elif grains['os'] == 'RedHat' %}
kibana-copy_systemd:
  file.managed:
    - source: salt://kibana/templates/kibana.service.tpl
    - name: /usr/lib/systemd/system/kibana.service
    - mode: 644
    - template: jinja
    - context:
      installdir: {{kibana_directory}}/kibana-{{ kibana_version }}
kibana-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload
{% endif %}

kibana-service:
  service.running:
    - name: kibana
    - enable: True
    - watch:
{% if grains['os'] == 'Ubuntu' %}
      - file: kibana-copy_kibana_upstart
{% elif grains['os'] == 'RedHat' %}
      - file: {{kibana_directory}}/kibana-{{ kibana_version }}/config/kibana.yml
{% endif %}
