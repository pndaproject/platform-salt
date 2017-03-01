## Install Jupyter Spark extension ##

{% set pnda_home_directory = pillar['pnda']['homedir'] %}
{% set virtual_env_dir = pnda_home_directory + '/jupyter' %}
{% set pip_index_url = pillar['pip']['index_url'] %}

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set extensions_package = 'jupyter-spark-0.3.0-patch.tar.gz' %}
{% set extensions_url = mirror_location + extensions_package %}

jupyter-extension-enable_widget_nbextensions:
  cmd.run:
    - name: {{ virtual_env_dir }}/bin/jupyter nbextension enable --py widgetsnbextension --system
    - unless: |
        {{ virtual_env_dir }}/bin/jupyter nbextension list --system|grep 'jupyter-spark/extension.*enabled'

jupyter-pip-requirements:
  file.managed:
    - name: {{ virtual_env_dir }}/requirements-jupyter-extensions.txt
    - source: salt://jupyter/templates/requirements-jupyter-extensions.txt.tpl
    - template: jinja
    - context:
      extensions_url: {{ extensions_url }}

# lxml improves perforance on server side communication to Spark
jupyter-extension_install_jupyter_spark:
  pip.installed:
    - requirements: {{ virtual_env_dir }}/requirements-jupyter-extensions.txt
    - python: python3
    - index_url: {{ pip_index_url }}
    - bin_env: {{ virtual_env_dir }}

jupyter-extension_jupyter_spark:
  cmd.run:
    - name: |
        {{ virtual_env_dir }}/bin/jupyter serverextension enable --py jupyter_spark --system &&
        {{ virtual_env_dir }}/bin/jupyter nbextension install --py jupyter_spark --system &&
        {{ virtual_env_dir }}/bin/jupyter nbextension enable --py jupyter_spark --system
    - unless: |
        {{ virtual_env_dir }}/bin/jupyter serverextension list --system|grep 'jupyter_spark.*enabled' &&
        {{ virtual_env_dir }}/bin/jupyter nbextension list --system|grep 'jupyter-spark/extension.*enabled'
    - require:
      - pip: jupyter-extension_install_jupyter_spark
