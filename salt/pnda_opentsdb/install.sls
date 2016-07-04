include:
  - python-pip

install_python_deps:
  pip.installed:
    - pkgs:
      - cm_api == 11.0.0
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip
