{% set kibana_version = pillar['kibana']['version'] %}
{% set kibana_directory = salt['pillar.get']('kibana:directory', '/opt/pnda') + '/kibana-' + kibana_version %}

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set kibana_package = 'kibana-' + kibana_version + '.tar.gz' %}
{% set kibana_url = mirror_location + kibana_package %}

kibana-kibana:
  group.present:
    - name: kibana
  user.present:
    - name: kibana
    - gid_from_name: True
    - groups:
      - kibana

kibana-dl_and_extract_kibana:
  archive.extracted:
    - name: {{ kibana_directory }}
    - source: {{ kibana_url }}
    - source_hash: {{ kibana_url }}.sha1.txt
    - user: kibana
    - group: kibana
    - archive_format: tar
    - tar_options: --strip-components=1
    - if_missing: {{ kibana_directory }}/bin/kibana

kibana-copy_configuration_kibana:
  file.managed:
    - name: {{ kibana_directory }}/config/kibana.yml
    - source: salt://kibana/files/kibana.yml
    - user: kibana
    - group: kibana

kibana-copy_kibana_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - source: salt://kibana/templates/kibana.init.conf.tpl
    - name: /etc/init/kibana.conf
{% elif grains['os'] in ('RedHat', 'CentOS') %}
    - source: salt://kibana/templates/kibana.service.tpl
    - name: /usr/lib/systemd/system/kibana.service
{% endif %}
    - mode: 644
    - template: jinja
    - context:
      installdir: {{ kibana_directory }}

{% if grains['os'] in ('RedHat', 'CentOS') %}
kibana-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable kibana
{%- endif %}

kibana-start_service:
  cmd.run:
    - name: 'service kibana stop || echo already stopped; service kibana start'
