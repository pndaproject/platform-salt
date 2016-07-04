# Install required python dependencies to run cloudera installation process

include:
  - python-pip

cdh-cloudera-api:
  pip.installed:
    - pkgs:
      - cm_api == 11.0.0
      - spur == 0.3.17
      - pywebhdfs
    - require:
      - pip: python-pip-install_python_pip
