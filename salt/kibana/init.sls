{% set kibana_version = salt['pillar.get']('kibana:version', '4.1.6-linux-x64') %}
{% set kibana_directory = salt['pillar.get']('kibana:directory', '/opt/pnda') %}

#TODO: see elasticsearch URL in param

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
    - source: https://download.elastic.co/kibana/kibana/kibana-{{ kibana_version }}.tar.gz
    - source_hash: https://download.elastic.co/kibana/kibana/kibana-{{ kibana_version }}.tar.gz.sha1.txt
    - archive_format: tar
    - if_missing: {{kibana_directory}}/kibana-{{kibana_version }}

kibana-copy_configuration_kibana:
  file.managed:
    - name: {{kibana_directory}}/kibana-{{ kibana_version }}/config/kibana.yml
    - source: salt://kibana/files/kibana.yml
    - user: kibana
    - group: kibana

kibana-copy_kibana_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - source: salt://kibana/templates/kibana.init.conf.tpl
    - name: /etc/init/kibana.conf
{% elif grains['os'] == 'RedHat' %}
    - source: salt://kibana/templates/kibana.service.tpl
    - name: /usr/lib/systemd/system/kibana.service
{% endif %}
    - mode: 644
    - template: jinja
    - context:
      installdir: {{kibana_directory}}/kibana-{{ kibana_version }}

{% if grains['os'] == 'RedHat' %}
kibana-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable kibana
{%- endif %}

kibana-start_service:
  cmd.run:
    - name: 'service kibana stop || echo already stopped; service kibana start'