{% set settings = salt['pillar.get']('opentsdb', {}) -%}
{% set opentsdb_version = settings.get('version', '2.2.0') %}
{% set opentsdb_hash = settings.get('release_hash', 'sha256=e82738703efa50cfdd42dd7741e3d5b78fc2bf8cd12352253fc1489d1dea1f60') %}

{% set opentsdb_deb_package = 'opentsdb-' + opentsdb_version + '_all.deb' %}
{% set opentsdb_deb_location = 'https://github.com/OpenTSDB/opentsdb/releases/download/v' + opentsdb_version + '/' + opentsdb_deb_package %}

include:
  - gnuplot
  - java

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
      - pkg: opentsdb-server
