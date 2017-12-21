{% set pip_index_url = pillar['pip']['index_url'] %}

{% if grains['hadoop.distro'] == 'HDP' %}
{% set anaconda_home = '/opt/pnda/anaconda' %}
{% else %}
{% set anaconda_home = '/opt/cloudera/parcels/Anaconda' %}
{% endif %}


{% if grains['os'] == 'Ubuntu' %}
dependency-install-libpq:
  pkg.installed:
    - name: {{ pillar['libpq-dev']['package-name'] }}
    - version: {{ pillar['libpq-dev']['version'] }}
    - ignore_epoch: True
{% else %}
dependency-install_gcc-dep:
  pkg.installed:
    - name: {{ pillar['gcc']['package-name'] }}
    - version: {{ pillar['gcc']['version'] }}
    - ignore_epoch: True

dependency-install_postgresql-devel:
  pkg.installed:
    - name: {{ pillar['postgresql-devel']['package-name'] }}
    - version: {{ pillar['postgresql-devel']['version'] }}
    - ignore_epoch: True
{% endif %}


jupyter-install_anaconda_deps:
  cmd.run:
    - name: export PATH={{ anaconda_home }}/bin:$PATH;pip install --index-url {{ pip_index_url }} cm-api==14.0.0 avro==1.8.1 ipython-sql==0.3.8 sql-magic==0.0.3 pymysql==0.7.11 psycopg2==2.7.3.2 impyla==0.14.0 thrift==0.9.3
