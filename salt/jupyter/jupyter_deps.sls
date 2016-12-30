include:
  - nodejs

jupyter-install_anaconda_deps:
  cmd.run:
    - name: export PATH=/opt/cloudera/parcels/Anaconda/bin:$PATH;pip install cm_api avro

jupyter-install_anaconda_ipywidgets:
  cmd.run:
    - name: export PATH=/opt/cloudera/parcels/Anaconda/bin:$PATH;conda install -c conda-forge ipywidgets

jupyter-install_configurable_http_proxy:
  npm.installed:
    - name: configurable-http-proxy
