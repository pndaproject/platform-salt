{% set settings = salt['pillar.get']('opentsdb', {}) -%}
{% set opentsdb_version = settings.get('version', '2.2.0') %}

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% if grains['os'] == 'Ubuntu' %}
{% set opentsdb_package = 'opentsdb-' + opentsdb_version + '_all.deb' %}
{% elif grains['os'] == 'RedHat' %}
{% set opentsdb_package = 'opentsdb-' + opentsdb_version + '.noarch.rpm' %}
{%- endif %}

{% set opentsdb_pkg_location = mirror_location + opentsdb_package %}

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