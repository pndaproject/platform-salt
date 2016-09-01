{% set namenodes_ips = salt['pnda.namenodes_ips']() %}
# Only take the first one
{% set namenode_ip = namenodes_ips[0] %}
{% set jupyter_notebook_version = pillar['jupyter']['version'] %}
{% set jupyter_config_dir = pillar['jupyter']['confdir'] %}
{% set jupyter_kernels_dir = pillar['jupyter']['kerneldir'] %}
{% set jupyterhub_version = pillar['jupyterhub']['version'] %}
{% set jupyterhub_config_dir = pillar['jupyterhub']['confdir'] %}
{% set os_user = salt['pillar.get']('os_user', 'cloud-user') %}
{% set pnda_home_directory = pillar['pnda']['homedir'] %}

include:
  - python-pip.pip3
  - .jupyter_deps
  - .extensions
  - cdh.cloudera-api
  - pnda.platform-libraries

#install jupyter notebook
jupyter-install_notebook:
  pip.installed:
    - name: notebook=={{ jupyter_notebook_version }}
    - bin_env: /usr/local/bin/pip3
    - upgrade: True
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip3
    - require_in:
      - cmd: jupyter-extension_jupyter_spark

# install jupyterhub
jupyter-install_jupyterhub:
  pip.installed:
    - name: jupyterhub=={{ jupyterhub_version }}
    - bin_env: /usr/local/bin/pip3
    - upgrade: True
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip3

# set up jupyter environment configuration
jupyter-enable_widget_nbextensions:
  cmd.run:
    - name: jupyter nbextension enable --py widgetsnbextension --system
    - require:
      - pip: jupyter-install_notebook

jupyter-create_nbconfig_dir:
  file.directory:
    - name: {{ jupyter_config_dir }}/nbconfig
    - makedirs: True

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
    - require:
      - file: jupyter-create_jupyterhub_config_dir

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

# install jupyterhub kernels (python2, python3, and pyspark)
jupyter-create_kernels_dir:
  file.directory:
    - name: {{ jupyter_kernels_dir }}

jupyter-install_python2_kernel:
  cmd.run:
    - name: '/opt/cloudera/parcels/Anaconda/bin/python -m ipykernel.kernelspec '

jupyter-create_pyspark_kernel_dir:
  file.directory:
    - name: {{ jupyter_kernels_dir }}/pyspark
    - require:
      - file: jupyter-create_kernels_dir

jupyter-copy_pyspark_kernel:
  file.managed:
    - source: salt://jupyter/templates/pyspark_kernel.json.tpl
    - name: {{ jupyter_kernels_dir }}/pyspark/kernel.json
    - template: jinja
    - require:
      - file: jupyter-create_pyspark_kernel_dir

#copy data-generator.py script
jupyter-copy_data_generator_script:
  file.managed:
    - source: salt://jupyter/files/data_generator.py
    - name: /home/{{ os_user }}/data_generator.py
    - mode: 777

# set up upstart script
jupyter-copy_upstart:
  file.managed:
    - source: salt://jupyter/templates/jupyterhub.conf.tpl
    - name: /etc/init/jupyterhub.conf
    - mode: 644
    - template: jinja
    - context:
      jupyterhub_config_dir: {{ jupyterhub_config_dir }}

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
