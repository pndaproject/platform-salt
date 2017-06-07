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
