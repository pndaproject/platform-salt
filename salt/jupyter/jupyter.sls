{% set pnda_home_directory = pillar['pnda']['homedir'] %}
{% set virtual_env_dir = pnda_home_directory + '/jupyter' %}
{% set pip_index_url = pillar['pip']['index_url'] %}
{% set jupyter_kernels_dir = '/usr/local/share/jupyter/kernels' %}
{% set app_packages_home = pnda_home_directory + '/app-packages' %}
{% set jupyter_extension_venv = pnda_home_directory + '/jupyter-extensions' %}
{% set pnda_user  = pillar['pnda']['user'] %}

{% if pillar['hadoop.distro'] == 'HDP' %}
{% set anaconda_home = '/opt/pnda/anaconda' %}
{% set spark_home = '/usr/hdp/current/spark-client' %}
{% set hadoop_conf_dir = '/etc/hadoop/conf' %}
{% else %}
{% set anaconda_home = '/opt/cloudera/parcels/Anaconda' %}
{% set spark_home = '/opt/cloudera/parcels/CDH/lib/spark' %}
{% set hadoop_conf_dir = '/etc/hadoop/conf.cloudera.yarn01' %}
{% endif %}

{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set jupyter_scala_package = mirror_location + 'jupyter-scala-0.4.2.tar.gz' %}
{% set jupyter_scala_dir = 'jupyter-scala-0.4.2' %}
{% set scala_install_dir = pnda_home_directory + '/scala' %}

{% set livy_package_name = 'livy-0.4.0-incubating-bin.zip' %}
{% set livy_install_dir = pnda_home_directory + '/livy' %}
{% set livy_package_ext_dir = 'livy-0.4.0-incubating-bin' %}
{% set livy_package = mirror_location + livy_package_name %}
{% set python_lib_dir = '/opt/pnda/jupyter/lib/python3.4/site-packages' %}

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

dependency-install_unzip:
  pkg.installed:
    - name: {{ pillar['unzip']['package-name'] }}
    - version: {{ pillar['unzip']['version'] }}
    - ignore_epoch: True

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

# Add scala to the supported kernels
scala-installation-dir:
  file.directory:
    - name: {{ scala_install_dir }}
    - mode: 755
    - makedirs: True

install-jupyter_scala:
  cmd.run:
    - cwd: {{ scala_install_dir }}
    - name: wget '{{ jupyter_scala_package }}' -O - | tar zx  && {{ scala_install_dir }}/{{ jupyter_scala_dir }}/jupyter-scala --force

jupyter-create_scala_kernel_dir:
  file.directory:
    - name: {{ jupyter_kernels_dir }}/jupyter_scala
    - makedirs: True

{% set all_users = salt['user.list_users']() %}
{% if 'root' in all_users %}
jupyter-copy_configs:
  cmd.run:
    - name: |
        mv /root/.local/share/jupyter/kernels/scala/* {{ jupyter_kernels_dir }}/jupyter_scala &&
        rm -rf /root/.local/share/jupyter/kernels/scala &&
        chmod -R 755 {{ jupyter_kernels_dir }}/jupyter_scala
{% endif %}

jupyter-copy_scala_kernel:
  file.managed:
    - source: salt://jupyter/templates/jupyter_scala_kernel.json.tpl
    - name: {{ jupyter_kernels_dir }}/jupyter_scala/kernel.json
    - template: jinja
    - mode: 755
    - require:
      - file: jupyter-create_scala_kernel_dir
    - defaults:
      jupyter_kernels_dir: {{ jupyter_kernels_dir }}

# Add sparkmagic to the supported kernel and install livy server
jupyter-create_livy_server_dir:
  file.directory:
    - name: {{ livy_install_dir }}
    - user: pnda
    - group: pnda
    - mode: 755
    - makedirs: True

livy-download_zip:
  cmd.run:
    - cwd: {{ livy_install_dir }}
    - name: wget {{ livy_package }}

livy-unpack_zip:
  cmd.run:
    - cwd: {{ livy_install_dir }}
    - name: unzip -o {{ livy_package_name }} && rm {{ livy_package_name }}
    - require:
      - cmd: livy-download_zip

livy-create_logs_dir:
  file.directory:
    - name: {{ livy_install_dir }}/{{ livy_package_ext_dir }}/logs
    - user: pnda
    - group: pnda
    - mode: 766
    - makedirs: True

livy-create_configuration:
  file.managed:
    - source : {{ livy_install_dir }}/{{ livy_package_ext_dir }}/conf/livy.conf.template
    - name : {{ livy_install_dir }}/{{ livy_package_ext_dir }}/conf/livy.conf

livy-update_configuration:
  file.append:
    - name: {{ livy_install_dir }}/{{ livy_package_ext_dir }}/conf/livy.conf
    - text: livy.spark.master = yarn-client

jupyter-scala_extension_spark:
  cmd.run:
    - name: |
        {{ virtual_env_dir }}/bin/jupyter nbextension enable --py widgetsnbextension --system &&
        {{ virtual_env_dir }}/bin/jupyter-kernelspec install  {{ python_lib_dir }}/sparkmagic/kernels/sparkkernel &&
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
        install_dir: {{ livy_install_dir }}
        spark_home: {{ spark_home }}
        hadoop_conf_dir: {{ hadoop_conf_dir }}
        livy_package_ext_dir: {{ livy_package_ext_dir }}

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
