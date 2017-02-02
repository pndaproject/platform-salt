{% set pip_index_url = salt['pillar.get']('pip:index_url', 'https://pypi.python.org/simple/') %}

include:
  - python-pip

python-pip-install-pip3-package:
  pkg.installed:
    - pkgs:
{% if grains['os'] == 'Ubuntu' %}
      - python3-pip
      - python3-dev
{% elif grains['os'] == 'RedHat' %}
      - python34-pip
      - python34-devel
{% endif %}

python-pip-install_python_pip3:
  pip.installed:
    - pkgs:
      - pip == 9.0.1
      - virtualenv == 15.1.0
    - index_url: {{ pip_index_url }}
    - bin_env: /usr/bin/pip3
    - upgrade: True
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip
      - pkg: python-pip-install-pip3-package
