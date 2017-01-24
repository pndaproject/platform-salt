python-pip-install-pip-package:
  pkg.installed:
    - pkgs:
      - python-pip
      - python-dev

python-pip-install_python_pip:
  pip.installed:
    - pkgs:
      - pip == 9.0.1
      - virtualenv == 15.1.0
    - upgrade: True
    - reload_modules: True
    - require:
      - pkg: python-pip-install-pip-package
