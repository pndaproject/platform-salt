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

curator-logs-dir:
  file.directory:
    - name: /var/log/pnda/curator
    - mode: 755
    - makedirs: True
    - recurse:
      - mode

curator-deploy-config:
  file.managed:
    - name: {{ virtual_env_dir }}/config.yml
    - source: salt://curator/files/config.yml

curator-deploy-action:
  file.managed:
    - name: {{ virtual_env_dir }}/action.yml
    - source: salt://curator/files/action.yml

curator-update-crontab-inc-curator:
  cron.present:
    - identifier: CURATOR-DELETE-INDICES
    - user: root
    - minute: 01
    - hour: 00
    - name: {{ virtual_env_dir }}/bin/curator --config {{ virtual_env_dir }}/config.yml {{ virtual_env_dir }}/action.yml
