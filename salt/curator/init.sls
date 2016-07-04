include:
  - python-pip

curator-python-elasticsearch-curator:
  pip.installed:
    - name: elasticsearch-curator
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip

curator-update-crontab-inc-curator:
  cron.present:
    - identifier: CURATOR-DELETE-INDICES
    - user: root
    - minute: 01
    - hour: 00
    - name: curator delete indices --older-than 6 --time-unit days --prefix logstash- --timestring \%Y.\%m.\%d >> /tmp/curator.log 2>&1
