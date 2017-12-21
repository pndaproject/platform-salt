{% set pnda_home_directory = pillar['pnda']['homedir'] %}
{% set virtual_env_dir = pnda_home_directory + '/jupyter' %}
{% set pip_index_url = pillar['pip']['index_url'] %}
{% set jupyter_kernels_dir = '/usr/local/share/jupyter/kernels' %}
{% set app_packages_home = pnda_home_directory + '/app-packages' %}
{% set jupyter_extension_venv = pnda_home_directory + '/jupyter-extensions' %}
{% set pnda_user  = pillar['pnda']['user'] %}
{% set wrapper_spark_home = '/usr/' %}

{% if grains['hadoop.distro'] == 'HDP' %}
{% set anaconda_home = '/opt/pnda/anaconda' %}
{% set spark_home = '/usr/hdp/current/spark-client' %}
{% set hadoop_conf_dir = '/etc/hadoop/conf' %}
{% set livy_dir = '/usr/hdp/current/livy-server' %}
{% else %}
{% set anaconda_home = '/opt/cloudera/parcels/Anaconda' %}
{% set spark_home = '/opt/cloudera/parcels/CDH/lib/spark' %}
{% set hadoop_conf_dir = '/etc/hadoop/conf.cloudera.yarn01' %}
{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set livy_version = pillar['livy']['release_version'] %}
{% set livy_package = 'livy-' + livy_version + '.tar.gz' %}
{% set livy_dir = pnda_home_directory + '/livy-' + livy_version %}
{% endif %}

{% set anaconda_python_lib = anaconda_home + '/lib/python2.7/site-packages/' %}
{% set jupyter_python_lib = virtual_env_dir + '/lib/python3.4/site-packages/' %}

include:
  - python-pip
  - python-pip.pip3
  - .jupyter_deps

{% if grains['os'] == 'Ubuntu' %}
dependency-install_dev_krb:
  pkg.installed:
    - name: {{ pillar['libkrb5-dev']['package-name'] }}
    - version: {{ pillar['libkrb5-dev']['version'] }}
    - ignore_epoch: True
{% endif %}

{% if grains['os'] == 'RedHat' %}
dependency-install_krb5_devel:
  pkg.installed:
    - name: {{ pillar['krb5-devel']['package-name'] }}
    - version: {{ pillar['krb5-devel']['version'] }}
    - ignore_epoch: True

dependency-install_gcc:
  pkg.installed:
    - name: {{ pillar['gcc']['package-name'] }}
    - version: {{ pillar['gcc']['version'] }}
    - ignore_epoch: True
{% endif %}

jupyter-create-venv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - python: python3
    - requirements: salt://jupyter/files/requirements-jupyter.txt
    - index_url: {{ pip_index_url }}
    - require:
      - pip: python-pip-install_python_pip

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

jupyter-create_pam_login_script:
  file.managed:
    - source: salt://jupyter/templates/jupyterhub-create_notebook_dir.sh.tpl
    - name: /root/create_notebook_dir.sh
    - user: root
    - group: root
    - mode: 744
    - template: jinja
    - defaults:
      example_notebooks_dir: '{{ pnda_home_directory }}/jupyter_notebooks'
      pnda_user: {{ pnda_user }} 

jupyter-create_pam_login_rule:
  file.append:
    - name: /etc/pam.d/login
    - text: |
        auth    required    pam_exec.so    debug log=/var/log/pnda/login.log /root/create_notebook_dir.sh

# install jupyter kernels (python2, python3, and pyspark)
jupyter-install_python2_kernel:
  cmd.run:
    - name: '{{ anaconda_home }}/bin/python -m ipykernel.kernelspec --name anacondapython2 --display-name "Python 2 (Anaconda)"'
    - require:
      - virtualenv: jupyter-create-venv

jupyter-create_pyspark_kernel_dir:
  file.directory:
    - name: {{ jupyter_kernels_dir }}/pyspark
    - makedirs: True

jupyter-copy_pyspark_kernel:
  file.managed:
    - source: salt://jupyter/templates/pyspark_kernel.json.tpl
    - name: {{ jupyter_kernels_dir }}/pyspark/kernel.json
    - template: jinja
    - require:
      - file: jupyter-create_pyspark_kernel_dir
    - defaults:
        anaconda_home: {{ anaconda_home }}
        wrapper_spark_home: {{ wrapper_spark_home }}
        spark_home: {{ spark_home }}
        hadoop_conf_dir: {{ hadoop_conf_dir }}
        app_packages_home: {{ app_packages_home }}
        jupyter_extension_venv: {{ jupyter_extension_venv }}

#copy data-generator.py script
jupyter-copy_data_generator_script:
  file.managed:
    - source: salt://jupyter/files/data_generator.py
    - name: {{ pnda_home_directory }}/data_generator.py
    - mode: 555

# Add sparkmagic to the supported kernel and install livy server
livy-create_logs_dir:
  file.directory:
    - name: {{ livy_dir }}/logs
    - user: pnda
    - group: pnda
    - mode: 766
    - makedirs: True

{% if grains['hadoop.distro'] == 'HDP' %}
livy-update_configuration_hdp:
  file.append:
    - name: {{ livy_dir }}/conf/livy.conf
    - text: livy.spark.master = yarn-client

{% else %}
livy-download:
  cmd.run:
    - cwd: {{ pnda_home_directory }}
    - name: wget {{ packages_server }}/{{ livy_package }} && tar xvf {{ livy_package }} && rm {{ livy_package }}

livy-update_configuration_cdh:
  file.append:
    - name: {{ livy_dir }}/conf/livy.conf
    - text: livy.spark.master = yarn-client
{% endif %}

jupyter-scala_extension_spark:
  cmd.run:
    - name: |
        {{ virtual_env_dir }}/bin/jupyter nbextension enable --py widgetsnbextension --system &&
        {{ virtual_env_dir }}/bin/jupyter-kernelspec install  {{ jupyter_python_lib }}/sparkmagic/kernels/sparkkernel &&
        {{ virtual_env_dir }}/bin/jupyter serverextension enable --py sparkmagic

jupyter-copy_scala_spark_kernel:
  file.managed:
    - source: salt://jupyter/templates/scala_spark_kernel.json.tpl
    - name: {{ jupyter_kernels_dir }}/sparkkernel/kernel.json
    - template: jinja
    - defaults:
        virtual_env_dir: {{ virtual_env_dir }}

livy-conf_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - name: /etc/init/livy.conf
    - source: salt://jupyter/templates/livy.conf.tpl
{% elif grains['os'] == 'RedHat' %}
    - name: /usr/lib/systemd/system/livy.service
    - source: salt://jupyter/templates/livy.service.tpl
{% endif %}
    - template: jinja
    - mode: 644
    - defaults:
        install_dir: {{ livy_dir }}
        spark_home: {{ spark_home }}
        hadoop_conf_dir: {{ hadoop_conf_dir }}

{% if grains['os'] == 'RedHat' %}
livy-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable livy
{%- endif %}

livy-server-start_service:
  service.running:
    - name: livy
    - enable: True
    - reload: True

{% if grains['hadoop.distro'] == 'CDH' %}
dependency-configurations-python2:
 cmd.run:
    - name: sed -i "s/if 'mssql' not in str(conn.dialect):/if config.autocommit and ('mssql' not in str(conn.dialect)):/" {{ anaconda_python_lib }}/sql/run.py && sed -i '/def __init__(self, shell):/i \    autocommit = Bool(True, config=True, help="Set autocommit mode")\n' {{ anaconda_python_lib }}/sql/magic.py
dependency-configurations-python3:
  cmd.run:
    - name: sed -i "s/if 'mssql' not in str(conn.dialect):/if config.autocommit and ('mssql' not in str(conn.dialect)):/" {{ jupyter_python_lib }}/sql/run.py && sed -i '/def __init__(self, shell):/i \    autocommit = Bool(True, config=True, help="Set autocommit mode")\n' {{ jupyter_python_lib }}/sql/magic.py
{% endif %}
