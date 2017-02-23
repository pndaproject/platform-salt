{% set pnda_home_directory = pillar['pnda']['homedir'] %}
{% set virtual_env_dir = pnda_home_directory + '/jupyter' %}

{% set jupyter_kernels_dir = '/usr/local/share/jupyter/kernels' %}
{% set os_user = salt['pillar.get']('os_user', 'cloud-user') %}
{% set pip_index_url = salt['pillar.get']('pip:index_url', 'https://pypi.python.org/simple/') %}

include:
  - python-pip
  - python-pip.pip3
  - .jupyter_deps

jupyter-create-venv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - python: python3
    - require:
      - pip: python-pip-install_python_pip
      - pip: python-pip-install_python_pip3

jupyter-install-requirements:
  pip.installed:
    - bin_env: {{ virtual_env_dir }}
    - index_url: {{ pip_index_url }}
    - requirements: salt://jupyter/files/requirements-jupyter.txt
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

# install jupyter kernels (python2, python3, and pyspark)
jupyter-install_python2_kernel:
  cmd.run:
    - name: '/opt/cloudera/parcels/Anaconda/bin/python -m ipykernel.kernelspec --name anacondapython2 --display-name "Python 2 (Anaconda)"'
    - require:
      - pip: jupyter-install-requirements

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

#copy data-generator.py script
jupyter-copy_data_generator_script:
  file.managed:
    - source: salt://jupyter/files/data_generator.py
    - name: /home/{{ os_user }}/data_generator.py
    - mode: 555
