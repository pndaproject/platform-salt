include:
  - python-pip

openstack-python-keystoneclient:
  pip.installed:
    - name: python-keystoneclient == 1.6.0
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip
