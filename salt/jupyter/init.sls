{% set pnda_home_directory = pillar['pnda']['homedir'] %}
{% set virtual_env_dir = pnda_home_directory + '/jupyter' %}

{% set jupyter_kernels_dir = '/usr/local/share/jupyter/kernels' %}
{% set jupyterhub_config_dir = '/etc/jupyterhub' %}
{% set os_user = salt['pillar.get']('os_user', 'cloud-user') %}

include:
  - python-pip
  - .jupyter_deps
  - .extensions
  - pnda.platform-libraries

jupyter-create-venv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - python: python3
    - requirements: salt://jupyter/files/requirements-jupyter.txt
    - require:
      - pip: python-pip-install_python_pip
    - require_in:
      - pip: jupyter-extension_install_jupyter_spark
      - cmd: jupyter-extension_jupyter_spark

# set up jupyter environment configuration
jupyter-enable_widget_nbextensions:
  cmd.run:
    - name: {{virtual_env_dir }}/bin/jupyter nbextension enable --py widgetsnbextension --system
    - require:
      - virtualenv: jupyter-create-venv

jupyter-create_notebooks_directory:
  file.directory:
    - name: '{{ pnda_home_directory }}/jupyter_notebooks'
    - user: {{ pillar['pnda']['user'] }}

jupyter-copy_initial_notebooks:
  file.recurse:
    - source: 'salt://jupyter/files/notebooks'
    - name: '{{ pnda_home_directory }}/jupyter_notebooks'
    - require:
      - file: jupyter-create_notebooks_directory

## install jupyter kernels (python2, python3, and pyspark)
#jupyter-create_kernels_dir:
#  file.directory:
#    - name: {{ jupyter_kernels_dir }}
#
#jupyter-install_python2_kernel:
#  cmd.run:
#    - name: '/opt/cloudera/parcels/Anaconda/bin/python -m ipykernel.kernelspec '
#
#jupyter-create_pyspark_kernel_dir:
#  file.directory:
#    - name: {{ jupyter_kernels_dir }}/pyspark
#    - require:
#      - file: jupyter-create_kernels_dir
#
#jupyter-copy_pyspark_kernel:
#  file.managed:
#    - source: salt://jupyter/templates/pyspark_kernel.json.tpl
#    - name: {{ jupyter_kernels_dir }}/pyspark/kernel.json
#    - template: jinja
#    - require:
#      - file: jupyter-create_pyspark_kernel_dir
#

#copy data-generator.py script
jupyter-copy_data_generator_script:
  file.managed:
    - source: salt://jupyter/files/data_generator.py
    - name: /home/{{ os_user }}/data_generator.py
    - mode: 777

# install jupyterhub
jupyter-install_jupyterhub:
  pip.installed:
    - requirements: salt://jupyter/files/requirements-jupyterhub.txt
    - bin_env: {{ virtual_env_dir }}
    - require:
      - virtualenv: jupyter-create-venv

# set up jupyterhub environment configuration
jupyter-create_jupyterhub_config_dir:
  file.directory:
    - name: {{ jupyterhub_config_dir }}
    - require:
      - pip: jupyter-install_jupyterhub

jupyter-create_hub_configuration:
  file.managed:
    - name: {{ jupyterhub_config_dir }}/jupyterhub_config.py
    - source: salt://jupyter/templates/jupyterhub_config.py.tpl
    - template: jinja
    - context:
      virtual_env_dir: {{ virtual_env_dir }}
    - require:
      - file: jupyter-create_jupyterhub_config_dir

# set up upstart script
jupyter-copy_upstart:
  file.managed:
    - source: salt://jupyter/templates/jupyterhub.conf.tpl
    - name: /etc/init/jupyterhub.conf
    - mode: 644
    - template: jinja
    - context:
      jupyterhub_config_dir: {{ jupyterhub_config_dir }}
      virtual_env_dir: {{ virtual_env_dir }}

jupyter-service_started:
  service.running:
    - name: jupyterhub
    - enable: True
    - reload: False
    - require:
      - pip: jupyter-install_jupyterhub
      - file: jupyter-copy_upstart
    - watch:
      - file: jupyter-copy_upstart
      - pip: jupyter-install_jupyterhub
      - file: jupyter-create_hub_configuration
