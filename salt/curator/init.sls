{% set flavor_cfg = pillar['pnda_flavor']['states'][sls] %}

include:
  - python-pip

curator-python-elasticsearch-curator:
  pip.installed:
    - name: elasticsearch-curator==3.5.1
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip

curator-update-crontab-inc-curator:
  cron.present:
    - identifier: CURATOR-DELETE-INDICES
    - user: root
    - minute: 01
    - hour: 00
    - name: /usr/local/bin/curator delete indices --older-than {{ flavor_cfg.days_to_keep }} --time-unit days --prefix logstash- --timestring \%Y.\%m.\%d >> /tmp/curator.log 2>&1

