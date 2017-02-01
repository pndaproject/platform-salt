python-pip-install-pip-package:
  pkg.installed:
    - pkgs:
{% if grains['os'] == 'Ubuntu' %}
      - python-pip
      - python-dev
{% elif grains['os'] == 'RedHat' %}
      - python2-pip
      - python-devel
{% endif %}

python-pip-install_python_pip:
  pip.installed:
    - pkgs:
      - pip == 9.0.1
      - virtualenv == 15.1.0
    - upgrade: True
    - reload_modules: True
    - require:
      - pkg: python-pip-install-pip-package
