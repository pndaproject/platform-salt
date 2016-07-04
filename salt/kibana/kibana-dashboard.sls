{% set user_dir = '/home/kibana' %}

include:
  - nodejs
  - python-pip

# install nodeenv
install-nodeenv:
  pip.installed:
    - name: nodeenv
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip

# create env directory
create-env_directory:
  file.directory:
    - name: {{ user_dir }}/latest-node
    - user: kibana

copy-dashboard_template:
  file.managed:
    - name: {{ user_dir }}/kibana.json
    - source: salt://kibana/files/kibana.json
    - user: kibana
    - group: kibana

# activate virtual environment
activate-env:
  cmd.script:
    - source: salt://kibana/files/activate-env.sh
    - cwd: {{ user_dir }}/latest-node
    - user: kibana
    - group: kibana
