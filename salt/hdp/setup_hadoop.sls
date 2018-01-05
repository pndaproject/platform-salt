{% set flavor_cfg = pillar['pnda_flavor']['states'][sls] %}

{% set scripts_location = '/tmp/pnda-install/' + sls %}
{% set pnda_cluster = salt['pnda.cluster_name']() %}
{% set hdp_p = salt['pillar.get']('hdp', {}) %}

{% set keystone_user = salt['pillar.get']('keystone.user', "") %}
{% set keystone_password = salt['pillar.get']('keystone.password', "") %}
{% set keystone_tenant = salt['pillar.get']('keystone.tenant', "") %}
{% set keystone_auth_url = salt['pillar.get']('keystone.auth_url', "") + '/tokens' %}
{% set region = salt['pillar.get']('keystone.region_name', "") %}
{% set mysql_host = salt['pnda.ip_addresses']('oozie_database')[0] %}
{% set aws_key = salt['pillar.get']('aws.archive_key', '') %}
{% set aws_secret_key = salt['pillar.get']('aws.archive_secret', '') %}
{% set pnda_graphite_host = salt['pnda.ip_addresses']('graphite')[0] %}

{% set pip_index_url = pillar['pip']['index_url'] %}

{%- set data_volume_list = [] %}
{%- for n in range(flavor_cfg.data_volumes_count) -%}
  {%- if flavor_cfg.data_volumes_count > 10 and n < 10 -%}
    {%- set prefix = '/data0' -%}
  {%- else -%}
    {%- set prefix = '/data' -%}
  {%- endif -%}
  {%- do data_volume_list.append(prefix ~ n ~ '/dn') %}
{%- endfor -%}
{%- set data_volumes = data_volume_list|join(",") %}

include:
  - python-pip

# Create a temporary virtualenv to execute the cm_setup scripts_location
hdp-create_tmp_virtualenv:
  virtualenv.managed:
    - name: {{ scripts_location }}/venv
    - requirements: salt://hdp/files/requirements-hdp_setup.txt
    - python: python2
    - index_url: {{ pip_index_url }}
    - require:
      - pip: python-pip-install_python_pip

hdp-copy_script_manager_installation_script:
  file.managed:
    - source: salt://hdp/files/hdp_setup.py
    - name: {{ scripts_location }}/hdp_setup.py

# Create a python configured scripts to call the hdp_setup.setup_hadoop function
hdp-create_hdp_configuration_script:
  file.managed:
    - name: {{ scripts_location}}/hdp_config.py
    - source: salt://hdp/templates/hdp_config.py.tpl
    - template: jinja
    - defaults:
        ips: {{ salt['mine.get']('G@hadoop:* and G@pnda_cluster:'+pnda_cluster, 'network.ip_addrs', expr_form='compound') }}
        hdp_config: {{ salt['mine.get']('G@hadoop:* and G@pnda_cluster:'+pnda_cluster, 'grains.items', expr_form='compound') }}
        cluster_name: {{ pnda_cluster }}
        hdp_core_stack_repo: {{ hdp_p.get('hdp_core_stack_repo', '') }}
        hdp_utils_stack_repo: {{ hdp_p.get('hdp_utils_stack_repo', '') }}

hdp-copy_flavor_config:
  file.managed:
    - source: salt://hdp/templates/{{ flavor_cfg.template_file }}.tpl
    - name: {{ scripts_location }}/cfg_flavor.py
    - template: jinja
    - defaults:
      keystone_user: {{ keystone_user }}
      keystone_tenant: {{ keystone_tenant }}
      keystone_auth_url: {{ keystone_auth_url }}
      keystone_password: {{ keystone_password }}
      region: {{ region }}
      mysql_host: {{ mysql_host }}
      aws_key: {{ aws_key }}
      aws_secret_key: {{ aws_secret_key }}
      data_volumes: {{ data_volumes }}
      pnda_graphite_host: {{ pnda_graphite_host }}

hdp-execute_hdp_installation_script:
  cmd.run:
    - name: {{ scripts_location }}/venv/bin/python {{ scripts_location }}/hdp_config.py
    - require:
      - virtualenv: hdp-create_tmp_virtualenv
      # watch the template setup state here
      - file: hdp-create_hdp_configuration_script
      - file: hdp-copy_script_manager_installation_script

hdp-fix_oozie_sharelib:
  cmd.run:
    - name: libvers=$(sudo -u hdfs hadoop fs -ls /user/oozie/share/lib/); sudo -u hdfs hadoop fs -copyFromLocal /usr/hdp/current/spark-client/lib/spark-assembly-*.jar /usr/hdp/current/spark-client/python/lib/py4j-0.9-src.zip /usr/hdp/current/spark-client/python/lib/pyspark.zip /user/oozie/share/lib/lib_${libvers##*_}/spark/ || true;

