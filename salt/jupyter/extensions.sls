## Install Jupyter Spark extension ##

{% set pnda_home_directory = pillar['pnda']['homedir'] %}
{% set virtual_env_dir = pnda_home_directory + '/jupyter' %}
{% set extra_mirror = salt['pillar.get']('extra:mirror', 'https://github.com/klyr/jupyter-spark/releases/download/0.3.0-patch/') %}
{% set jupyter_ext_url = extra_mirror +  'jupyter-spark-0.3.0-patch.tar.gz' %}
{% set pip_index_url = salt['pillar.get']('pip:index_url', 'https://pypi.python.org/simple/') %}

jupyter-extension-enable_widget_nbextensions:
  cmd.run:
    - name: {{ virtual_env_dir }}/bin/jupyter nbextension enable --py widgetsnbextension --system
    - unless: |
        {{ virtual_env_dir }}/bin/jupyter nbextension list --system|grep 'jupyter-spark/extension.*enabled'

jupyter-extension_install_jupyter_spark_requirements:
  pip.installed:
    - index_url: {{ pip_index_url }}  
    - requirements: salt://jupyter/files/requirements-jupyter-spark-patch.txt
    - bin_env: {{ virtual_env_dir }}

# lxml improves perforance on server side communication to Spark
jupyter-extension_install_jupyter_spark:
  pip.installed:
    - pkgs:
      - {{ jupyter_ext_url }}
      - lxml==3.6.4
    - index_url: {{ pip_index_url }}
    - bin_env: {{ virtual_env_dir }}
    - require:
      - pip: jupyter-extension_install_jupyter_spark_requirements

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
