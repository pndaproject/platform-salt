include:
  - nodejs
  - python-pip
  - python-pip.pip3

jupyter-install_dependencies:
  pkg.installed:
    - pkgs:
      - g++
      - libfreetype6-dev
      - libxft-dev
      - pkg-config
      - libzmq3-dev

jupyter-install_pip2_deps:
  pip.installed:
    - pkgs:
      - matplotlib
      - pyzmq
      - ipykernel
      - ipywidgets
      - avro
      - cm_api == 11.0.0
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip

jupyter-install_pip3_deps:
  pip.installed:
    - pkgs:
      - pyparsing == 2.1.1
      - matplotlib
      - pyzmq
      - ipywidgets
      - avro
    - bin_env: /usr/local/bin/pip3
    - reload_modules: True
    - require:
      - pip: python-pip-install_python_pip3

jupyter-install_anaconda_deps:
  cmd.run:
    - name: export PATH=/opt/cloudera/parcels/Anaconda/bin:$PATH;pip install cm_api avro

jupyter-install_anaconda_ipywidgets:
  cmd.run:
    - name: export PATH=/opt/cloudera/parcels/Anaconda/bin:$PATH;conda install -c conda-forge ipywidgets

jupyter-install_configurable_http_proxy:
  npm.installed:
    - name: configurable-http-proxy