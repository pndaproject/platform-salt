{% from "graphite-api/map.jinja" import config with context %}
{% set flavor_cfg = pillar['pnda_flavor']['states'][sls] %}

graphite-api-carbon-install:
  pkg.installed:
    - name: {{ config.carbon_package }}

graphite-api-carbon-configure:
  file.managed:
    - name: /etc/carbon/storage-schemas.conf
    - source: salt://graphite-api/files/storage-schemas.conf.tpl
    - template: jinja
    - context:
      retentions: {{ flavor_cfg.retention_spark_metrics }}
    - require:
      - pkg: graphite-api-carbon-install

graphite-api-carbon-whitelist-configure:
  file.managed:
    - name: /etc/carbon/whitelist.conf
    - source: salt://graphite-api/files/whitelist.conf
    - require:
      - pkg: graphite-api-carbon-install

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

graphite-api-install-graphite:
  pkg.installed:
    - name: graphite-api

graphite-api-configure-default:
  file.managed:
    - name: {{ config.graphite_api_default }}
    - source: salt://graphite-api/files/{{ config.graphite_api_default_src }}

graphite-api-configure:
  file.managed:
    - name: /etc/graphite-api.yaml
    - source: salt://graphite-api/files/graphite-api.yaml.redhat

graphite-api-enable-and-start:
  service.running:
    - name: graphite-api
    - enable: True
    - watch:
      - pkg: graphite-api-install-graphite
      - file: graphite-api-configure-default
      - file: graphite-api-configure
