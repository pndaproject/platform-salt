{% set flavor_cfg = pillar['pnda_flavor']['states'][sls] %}
{% set virtual_env_dir = pillar['pnda']['homedir'] + "/elasticsearch-curator" %}
{% set pip_index_url = pillar['pip']['index_url'] %}

include:
  - python-pip

curator-python-elasticsearch-curator:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - requirements: salt://curator/files/requirements.txt
    - python: python2
    - index_url: {{ pip_index_url }}
    - require:
      - pip: python-pip-install_python_pip

curator-update-crontab-inc-curator:
  cron.present:
    - identifier: CURATOR-DELETE-INDICES
    - user: root
    - minute: 01
    - hour: 00
    - name: {{ virtual_env_dir }}/bin/curator delete indices --older-than {{ flavor_cfg.days_to_keep }} --time-unit days --prefix logstash- --timestring \%Y.\%m.\%d >> /tmp/curator.log 2>&1
