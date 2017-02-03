{% set pnda_home_directory = pillar['pnda']['homedir'] %}
{% set virtual_env_dir = pnda_home_directory + '/jupyter' %}
{% set pip_index_url = salt['pillar.get']('pip:index_url', 'https://pypi.python.org/simple/') %}
{% set npm_registry = salt['pillar.get']('npm:registry', 'https://registry.npmjs.org/') %}

{% set jupyterhub_config_dir = '/etc/jupyterhub' %}

include:
  - nodejs

jupyterhub-install:
  pip.installed:
    - requirements: salt://jupyter/files/requirements-jupyterhub.txt
    - bin_env: {{ virtual_env_dir }}
    - index_url: {{ pip_index_url }}
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
    - registry: {{ npm_registry }}
    - require:
      - pkg: nodejs-install_useful_packages

# set up upstart script
jupyterhub-copy_upstart:
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

jupyterhub-service_started:
  service.running:
    - name: jupyterhub
    - enable: True
    - reload: False
    - require:
      - pip: jupyterhub-install
      - file: jupyterhub-copy_upstart
      - npm: jupyterhub-install_configurable_http_proxy
    - watch:
      - file: jupyterhub-copy_upstart
      - pip: jupyterhub-install
      - file: jupyterhub-create_configuration
