{% set settings = salt['pillar.get']('opentsdb', {}) -%}
{% set opentsdb_version = settings.get('version', '2.2.0') %}
{% set opentsdb_hash = settings.get('release_hash', 'sha256=e82738703efa50cfdd42dd7741e3d5b78fc2bf8cd12352253fc1489d1dea1f60') %}
{% set extra_mirror = salt['pillar.get']('extra:mirror', 'https://github.com/OpenTSDB/opentsdb/releases/download/v') %}

{% if grains['os'] == 'Ubuntu' %}
{% set opentsdb_package = 'opentsdb-' + opentsdb_version + '_all.deb' %}
{% elif grains['os'] == 'RedHat' %}
{% set opentsdb_package = 'opentsdb-' + opentsdb_version + '.noarch.rpm' %}
{%- endif %}

{% set opentsdb_pkg_location = extra_mirror + opentsdb_version + '/' + opentsdb_package %}

include:
  - gnuplot
  - java

opentsdb-server:
  pkg.installed:
    - sources:
      - opentsdb: {{ opentsdb_pkg_location }}

{% if grains['os'] == 'Ubuntu' %}
opentsdb-copy_defaults:
  file.managed:
    - name: /etc/default/opentsdb
    - source: salt://opentsdb/files/opentsdb.default
{% elif grains['os'] == 'RedHat' %}
opentsdb-copy_service:
  file.managed:
    - name: /usr/lib/systemd/system/opentsdb.service
    - source: salt://opentsdb/templates/opentsdb.service.tpl
    - template: jinja
{%- endif %}

{% if grains['os'] == 'RedHat' %}
opentsdb-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable opentsdb
{%- endif %}

opentsdb-start_service:
  cmd.run:
    - name: 'service opentsdb stop || echo already stopped; service opentsdb start'