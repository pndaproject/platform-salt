{% set pnda_home_directory = pillar['pnda']['homedir'] %}
{% set virtual_env_dir = pnda_home_directory + '/jupyter' %}
{% set pip_index_url = salt['pillar.get']('pip:index_url', 'https://pypi.python.org/simple/') %}

{% set jupyterhub_config_dir = '/etc/jupyterhub' %}

include:
  - nodejs

jupyterhub-install:
  pip.installed:
    - requirements: salt://jupyter/files/requirements-jupyterhub.txt
    - index_url: {{ pip_index_url }}
    - bin_env: {{ virtual_env_dir }}
    - require:
      - virtualenv: jupyter-create-venv

jupyterhub-create_config_dir:
  file.directory:
    - name: {{ jupyterhub_config_dir }}
    - require:
      - pip: jupyterhub-install

jupyterhub-create_configuration:
  file.managed:
    - name: {{ jupyterhub_config_dir }}/jupyterhub_config.py
    - source: salt://jupyter/templates/jupyterhub_config.py.tpl
    - template: jinja
    - context:
      virtual_env_dir: {{ virtual_env_dir }}
    - require:
      - file: jupyterhub-create_config_dir

jupyterhub-install_configurable_http_proxy:
  npm.installed:
    - name: configurable-http-proxy
    - require:
      - npm: nodejs-update_npm

jupyterhub-create_log_dir:
  file.directory:
    - name: /var/log/pnda/jupyter
    - makedirs: True

# set up service script
jupyterhub-copy_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - source: salt://jupyter/templates/jupyterhub.conf.tpl
    - name: /etc/init/jupyterhub.conf
{% elif grains['os'] == 'RedHat' %}
    - name: /usr/lib/systemd/system/jupyterhub.service
    - source: salt://jupyter/templates/jupyterhub.service.tpl
{%- endif %}
    - mode: 644
    - template: jinja
    - context:
      jupyterhub_config_dir: {{ jupyterhub_config_dir }}
      virtual_env_dir: {{ virtual_env_dir }}

{% if grains['os'] == 'RedHat' %}
jupyterhub-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable jupyterhub
{%- endif %}

jupyterhub-service_started:
  cmd.run:
    - name: 'service jupyterhub stop || echo already stopped; service jupyterhub start'
    - require:
      - pip: jupyterhub-install
      - file: jupyterhub-copy_service
      - npm: jupyterhub-install_configurable_http_proxy

