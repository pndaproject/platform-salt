{% set dirs = ['/data0'] %}

cdh-Create data directories:
  file.directory:
    - names: {{ dirs }}
    - makedirs: True
