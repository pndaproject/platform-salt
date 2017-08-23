{% set pnda_home_directory = pillar['pnda']['homedir'] %}
{% set virtual_env_dir = pnda_home_directory + '/jupyter' %}
{% set pip_index_url = pillar['pip']['index_url'] %}

{% set jupyter_kernels_dir = '/usr/local/share/jupyter/kernels' %}

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
{% set scala_install_dir = pnda_home_directory + '/scala' %}
{% set livy_install_dir = pnda_home_directory + '/livy' %}

{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set scala_package = mirror_location + 'scala-2.11.2.tgz' %}
{% set jupyter_scala_package = mirror_location + 'jupyter-scala_2.11.6-0.2.0-SNAPSHOT.tar.xz' %}
{% set jupyter_scala_tarball = 'jupyter-scala_2.11.6-0.2.0-SNAPSHOT.tar.xz' %}
{% set jupyter_scala_dir= 'jupyter-scala_2.11.6-0.2.0-SNAPSHOT' %}

{% set livy_package_name = 'livy-0.4.0-incubating-bin-RC2.zip' %}
{% set livy_package = mirror_location + livy_package_name %}
{% set python_lib_dir = salt['cmd.run']('python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())"') %}

include:
  - python-pip
  - python-pip.pip3
  - .jupyter_deps

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

install-scala:
  cmd.run:
    - cwd: {{ scala_install_dir }}
    - name: wget '{{ scala_package }}'  -O - |  tar zx

jupyter-scala_kernel_config:
    cmd.run:
      - cwd: {{ scala_install_dir }}
      - name: wget '{{ jupyter_scala_package }}' && tar -xvf {{ jupyter_scala_tarball }}
      - unless: test -d {{ scala_install_dir }}/{{ jupyter_scala_dir}}

jupyter-create_scala_kernel_dir:
  file.directory:
    - name: {{ jupyter_kernels_dir }}/scala
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

jupyter-copy_scala_kernel:
  file.managed:
    - source: salt://jupyter/templates/scala_kernel.json.tpl
    - name: {{ jupyter_kernels_dir }}/scala/kernel.json
    - template: jinja
    - require:
      - file: jupyter-create_scala_kernel_dir
    - defaults:
        jupyter_scala_dir: {{ jupyter_scala_dir }}
        scala_install_dir: {{ scala_install_dir }}

# Add sparkmagic to the supported kernel
jupyter-create_livy_server_dir:
  file.directory:
    - name: {{ livy_install_dir }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

install-livy:
  cmd.run:
    - cwd: {{ livy_install_dir }}
    - name: wget '{{ livy_package }}' |  && unzip livy_package_name }}
  file.directory:
    - name: {{ livy_install_dir }}/{{ livy_package_name }}/logs
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

start-livy-server:
  cmd.run:
    - cwd: {{ livy_install_dir }}
    - name: {{ livy_package_name }}/bin/livy-server

jupyter-scala_extension_spark:
  cmd.run:
    - name: |
        {{ virtual_env_dir }}/bin/jupyter nbextension enable --py widgetsnbextension --system &&
        {{ python_lib_dir }}/jupyter-kernelspec install sparkmagic/kernels/sparkkernel &&
        {{ virtual_env_dir }}/bin/jupyter serverextension enable --py sparkmagic