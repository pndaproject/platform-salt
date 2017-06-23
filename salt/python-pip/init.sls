{% set pip_index_url = pillar['pip']['index_url'] %}

python-pip-install_python_pip_pkg:
  pkg.installed:
    - name: {{ pillar['python-pip']['package-name'] }}
    - version: {{ pillar['python-pip']['version'] }}
    - ignore_epoch: True

python-pip-install_python_dev_pkg:
  pkg.installed:
    - name: {{ pillar['python-dev']['package-name'] }}
    - version : {{ pillar['python-dev']['version'] }}
    - ignore_epoch: True

python-pip-install_python_pip:
  pip.installed:
    - pkgs:
      - pip == 9.0.1
      - virtualenv == 15.1.0
    - upgrade: True
    - reload_modules: True
    - index_url: {{ pip_index_url }}
    - require:
      - pkg: python-pip-install_python_pip_pkg
      - pkg: python-pip-install_python_dev_pkg