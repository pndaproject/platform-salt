{% set settings = salt['pillar.get']('opentsdb', {}) -%}
{% set opentsdb_version = settings.get('version', '2.2.0RC1') %}
{% set opentsdb_hash = settings.get('release_hash', 'sha256=199f60f31c8f72948d0e5a2c4695aedcb114360a77c4246b16587f07028f8068') %}

{% set opentsdb_deb_package = 'opentsdb-' + opentsdb_version + '_all.deb' %}
{% set opentsdb_deb_location = 'https://github.com/OpenTSDB/opentsdb/releases/download/v' + opentsdb_version + '/' + opentsdb_deb_package %}

include:
  - gnuplot
  - java

opentsdb-download-opentsdb-package:
  file.managed:
    - name: /tmp/{{ opentsdb_deb_package }}
    - source: {{ opentsdb_deb_location }}
    - source_hash: {{ opentsdb_hash }}

opentsdb-server:
  pkg.installed:
    - sources:
      - opentsdb: {{ opentsdb_deb_location }}

opentsdb-service_start:
  service.running:
    - name: opentsdb
    - enable: True
    - reload: True
    - watch:
      - file: /etc/opentsdb/opentsdb.conf
      - file: /etc/default/opentsdb
      - file: opentsdb-download-opentsdb-package
