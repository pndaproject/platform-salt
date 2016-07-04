{% set namenodes_ips = salt['pnda.namenodes_ips']() %}
# Only take the first one
{% set namenode_ip = namenodes_ips[0] %}
{% set jupyter_notebook_version = salt['pillar.get']('jupyter:version', '') %}
{% set jupyterhub_version = salt['pillar.get']('jupyterhub:version', '') %}
{% set jupyter_config_dir = salt['pillar.get']('jupyter:confdir', '') %}
{% set jupyter_kernels_dir = salt['pillar.get']('jupyter:kerneldir', '') %}
{% set jupyterhub_config_dir = salt['pillar.get']('jupyterhub:confdir', '') %}
{% set os_user = salt['pillar.get']('os_user', 'cloud-user') %}

include:
  - python-pip.pip3
  - .jupyter_deps
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
    - name: jupyter nbextension enable --py widgetsnbextension

jupyter-create_nbconfig_dir:
  file.directory:
    - name: {{ jupyter_config_dir }}/nbconfig
    - makedirs: True

jupyter-create_notebook_config:
  file.managed:
    - source: salt://jupyter/files/notebook.json
    - name: {{ jupyter_config_dir }}/nbconfig/notebook.json

# set up jupyterhub environment configuration
jupyter-create_jupyterhub_config_dir:
  file.directory:
    - name: {{ jupyterhub_config_dir }}

jupyter-create_hub_configuration:
  file.managed:
    - name: {{ jupyterhub_config_dir }}/jupyterhub_config.py
    - source: salt://jupyter/templates/jupyterhub_config.py.tpl
    - template: jinja

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

jupyter-copy_pyspark_kernel:
  file.managed:
    - source: salt://jupyter/templates/pyspark_kernel.json.tpl
    - name: {{ jupyter_kernels_dir }}/pyspark/kernel.json
    - template: jinja

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

# safely start jupyterhub service
jupyter-stop_jupyterhub:
  cmd.run:
    - name: 'initctl stop jupyterhub || echo app already stopped'
    - user: root
    - group: root

jupyter-start_jupyterhub:
  cmd.run:
    - name: 'initctl start jupyterhub'
    - user: root
    - group: root
