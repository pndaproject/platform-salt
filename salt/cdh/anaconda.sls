cdh-conda_cmd_link:
  file.managed:
    - name: /usr/local/bin/conda
    - source: salt://anaconda/templates/conda-cmd.tpl
    - template: jinja
    - mode: 0755
    - defaults:
        anaconda_bin_dir: /opt/cloudera/parcels/Anaconda/bin