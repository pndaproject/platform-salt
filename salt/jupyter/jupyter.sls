{% set pnda_home_directory = pillar['pnda']['homedir'] %}
{% set virtual_env_dir = pnda_home_directory + '/jupyter' %}
{% set pip_index_url = pillar['pip']['index_url'] %}
{% set jupyter_kernels_dir = '/usr/local/share/jupyter/kernels' %}
{% set app_packages_home = pnda_home_directory + '/app-packages' %}
{% set jupyter_extension_venv = pnda_home_directory + '/jupyter-extensions' %}
{% set pnda_user  = pillar['pnda']['user'] %}
{% set wrapper_spark_home = pillar['resource_manager']['path'] %}
{% set features = salt['pillar.get']('features', []) %}
{% set anaconda_home = '/opt/pnda/anaconda' %}
{% if grains['hadoop.distro'] == 'HDP' %}
{% set spark_home = '/usr/hdp/current/spark-client' %}
{% set spark2_home = '/usr/hdp/current/spark2-client' %}
{% set hadoop_conf_dir = '/etc/hadoop/conf' %}
{% set py4j_src = spark2_home + '/python/lib/py4j-*.zip' %}
{% set spark_examples_jar_src = spark2_home + '/examples/jars/spark-examples_*.jar' %}
{% else %}
{% set spark_home = '/opt/cloudera/parcels/CDH/lib/spark' %}
{% set hadoop_conf_dir = '/etc/hadoop/conf.cloudera.yarn01' %}
{% set packages_server = pillar['packages_server']['base_uri'] %}
{% endif %}
{% set anaconda_python_lib = anaconda_home + '/lib/python2.7/site-packages/' %}
{% set jupyter_python_lib = virtual_env_dir + '/lib/python3.4/site-packages/' %}

include:
  - python-pip
  - python-pip.pip3
  - .jupyter_deps

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

jupyter-create-venv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - python: python3.4
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
# BEGIN EXPERIMENTAL
{% if 'EXPERIMENTAL' not in features %}
    - exclude_pat: "PNDA minimal Spark notebook*"
{% endif %}
# END EXPERIMENTAL
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

#install pyspark2 kernel #
{% if grains['hadoop.distro'] == 'HDP' %}
jupyter-create_pyspark2_kernel_dir:
  file.directory:
    - name: {{ jupyter_kernels_dir }}/pyspark2
    - makedirs: True

jupyter-copy_pyspark2_kernel:
  file.managed:
    - source: salt://jupyter/templates/pyspark2_kernel.json.tpl
    - name: {{ jupyter_kernels_dir }}/pyspark2/kernel.json
    - template: jinja
    - require:
      - file: jupyter-create_pyspark2_kernel_dir
    - defaults:
        anaconda_home: {{ anaconda_home }}
        wrapper_spark_home: {{ wrapper_spark_home }}
        spark2_home: {{ spark2_home }}
        hadoop_conf_dir: {{ hadoop_conf_dir }}
        app_packages_home: {{ app_packages_home }}
        jupyter_extension_venv: {{ jupyter_extension_venv }}

# create soft link to py4j
jupyter-symlink_py4j:
  cmd.run:
    - name: 'ln -s {{ py4j_src }} {{ spark2_home }}/python/lib/py4j.zip'
    - unless: ls {{ spark2_home }}/python/lib/py4j.zip

# create soft link to spark2 examples jar
jupyter-symlink_spark2_examples_jar:
  cmd.run:
    - name: 'ln -s {{ spark_examples_jar_src }} {{ spark2_home }}/examples/jars/spark2_examples.jar'
    - unless: ls {{ spark2_home }}/examples/jars/spark2_examples.jar
{% endif %}

{% if grains['hadoop.distro'] == 'CDH' %}
dependency-configurations-python2:
 cmd.run:
    - name: sed -i "s/if 'mssql' not in str(conn.dialect):/if config.autocommit and ('mssql' not in str(conn.dialect)):/" {{ anaconda_python_lib }}/sql/run.py && sed -i '/def __init__(self, shell):/i \    autocommit = Bool(True, config=True, help="Set autocommit mode")\n' {{ anaconda_python_lib }}/sql/magic.py
dependency-configurations-python3:
  cmd.run:
    - name: sed -i "s/if 'mssql' not in str(conn.dialect):/if config.autocommit and ('mssql' not in str(conn.dialect)):/" {{ jupyter_python_lib }}/sql/run.py && sed -i '/def __init__(self, shell):/i \    autocommit = Bool(True, config=True, help="Set autocommit mode")\n' {{ jupyter_python_lib }}/sql/magic.py
{% endif %}
