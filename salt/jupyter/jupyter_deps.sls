{% set pip_index_url = salt['pillar.get']('pip:index_url', 'https://pypi.python.org/simple/') %}

jupyter-install_anaconda_deps:
  cmd.run:
    - name: export PATH=/opt/cloudera/parcels/Anaconda/bin:$PATH;pip install --index-url {{ pip_index_url }} cm-api==14.0.0 avro==1.8.1

jupyter-install_anaconda_ipywidgets:
  cmd.run:
    - name: export PATH=/opt/cloudera/parcels/Anaconda/bin:$PATH;conda install -c conda-forge ipywidgets
