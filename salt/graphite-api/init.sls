{% from "graphite-api/map.jinja" import config with context %}

graphite-api-carbon-install:
  pkg.installed:
    - name: {{ config.carbon_package }}

graphite-api-carbon-configure:
  file.managed:
    - name: /etc/carbon/storage-schemas.conf
    - source: salt://graphite-api/files/storage-schemas.conf
    - require:
      - pkg: graphite-api-carbon-install

graphite-api-carbon-whitelist-configure:
  file.managed:
    - name: /etc/carbon/whitelist.conf
    - source: salt://graphite-api/files/whitelist.conf
    - require:
      - pkg: graphite-api-carbon-install

{% if grains['os'] == 'Ubuntu' %}
graphite-api-carbon-enable-ubuntu:
  file.managed:
    - name: /etc/default/graphite-carbon
    - source: salt://graphite-api/files/graphite-carbon.default
    - user: root
    - group: root
    - mode: 644
    - require:
      - pkg: graphite-api-carbon-install
{% endif %}

graphite-api-carbon-whitelist-enable:
  file.replace:
    - name: /etc/carbon/carbon.conf
    - pattern: '# USE_WHITELIST = False'
    - repl: USE_WHITELIST = True
    - backup: .bkp
    - require:
      - pkg: graphite-api-carbon-install

graphite-api-carbon-enable-and-start:
  service.running:
    - name: carbon-cache
    - enable: True
    - watch:
      - pkg: graphite-api-carbon-install
      - file: graphite-api-carbon-configure
      - file: graphite-api-carbon-whitelist-configure
      - file: /etc/carbon/carbon.conf
{% if grains['os'] == 'Ubuntu' %}
      - file: graphite-api-carbon-enable-ubuntu
{% endif %}

{% if grains['os'] == 'Ubuntu' %}
{% set misc_packages_path = pillar['pnda_mirror']['base_url'] + pillar['pnda_mirror']['misc_packages_path'] %}
{% set graphite_api_deb_package = misc_packages_path + 'graphite-api_1.1.2-1447943657-ubuntu14.04_amd64.deb' %}
{%- endif %}

graphite-api-install-graphite:
  pkg.installed:
{% if grains['os'] in ('RedHat', 'CentOS') %}
    - name: graphite-api
{% elif grains['os'] == 'Ubuntu' %}
    - sources:
      - graphite-api: {{ graphite_api_deb_package }}
{% endif %}

graphite-api-configure-default:
  file.managed:
    - name: {{ config.graphite_api_default }}
    - source: salt://graphite-api/files/{{ config.graphite_api_default_src }}

graphite-api-configure:
  file.managed:
    - name: /etc/graphite-api.yaml
{% if grains['os'] in ('RedHat', 'CentOS') %}
    - source: salt://graphite-api/files/graphite-api.yaml.redhat
{% elif grains['os'] == 'Ubuntu' %}
    - source: salt://graphite-api/files/graphite-api.yaml.debian
{% endif %}

graphite-api-enable-and-start:
  service.running:
    - name: graphite-api
    - enable: True
    - watch:
      - pkg: graphite-api-install-graphite
      - file: graphite-api-configure-default
      - file: graphite-api-configure
