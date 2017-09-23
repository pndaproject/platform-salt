{% set pip_index_url = pillar['pip']['index_url'] %}

{% if pillar['hadoop.distro'] == 'HDP' %}
{% set anaconda_home = '/opt/pnda/anaconda' %}
{% else %}
{% set anaconda_home = '/opt/cloudera/parcels/Anaconda' %}
{% endif %}

jupyter-install_anaconda_deps:
  cmd.run:
    - name: export PATH={{ anaconda_home }}/bin:$PATH;pip install --index-url {{ pip_index_url }} cm-api==14.0.0 avro==1.8.1
