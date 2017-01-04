include:
  - python-pip

python-pip-install-pip3-package:
  pkg.installed:
    - pkgs:
      - python3-pip
      - python3-dev

python-pip-install_python_pip3:
  pip.installed:
    - pkgs:
      - pip == 9.0.1
      - virtualenv == 15.1.0
    - bin_env: /usr/bin/pip3
    - upgrade: True
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip
      - pkg: python-pip-install-pip3-package
