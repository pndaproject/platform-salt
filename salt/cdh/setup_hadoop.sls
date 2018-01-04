{% set flavor_cfg = pillar['pnda_flavor']['states'][sls] %}

{% set scripts_location = '/tmp/pnda-install/' + sls %}
{% set pnda_cluster = salt['pnda.cluster_name']() %}
{% set cloudera_cdh_repo = pillar['cloudera']['parcel_repo'] %}
{% set cloudera_cdh_version = pillar['cloudera']['parcel_version'] %}

{% set keystone_user = salt['pillar.get']('keystone.user', "") %}
{% set keystone_password = salt['pillar.get']('keystone.password', "") %}
{% set keystone_tenant = salt['pillar.get']('keystone.tenant', "") %}
{% set keystone_auth_url = salt['pillar.get']('keystone.auth_url', "") + '/tokens' %}
{% set region = salt['pillar.get']('keystone.region_name', "") %}
{% set mysql_host = salt['pnda.ip_addresses']('oozie_database')[0] %}
{% set aws_key = salt['pillar.get']('aws.archive_key', '') %}
{% set aws_secret_key = salt['pillar.get']('aws.archive_secret', '') %}
{% set pip_index_url = pillar['pip']['index_url'] %}
{% set pnda_home = pillar['pnda']['homedir'] %}
{% set app_packages_dir = pnda_home + "/apps-packages" %}
{% set pnda_graphite_host = salt['pnda.ip_addresses']('graphite')[0] %}

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

cdh-install_deps_ffi:
  pkg.installed:
    - name: {{ pillar['libffi-dev']['package-name'] }}
    - version: {{ pillar['libffi-dev']['version'] }}
    - ignore_epoch: True

cdh-install_deps_ssl:
  pkg.installed:
    - name: {{ pillar['libssl-dev']['package-name'] }}
    - version: {{ pillar['libssl-dev']['version'] }}
    - ignore_epoch: True

# Create a temporary virtualenv to execute the cm_setup scripts_location
cdh-create_tmp_virtualenv:
  virtualenv.managed:
    - name: {{ scripts_location }}/venv
    - requirements: salt://cdh/files/requirements-cm_setup.txt
    - python: python2
    - index_url: {{ pip_index_url }}
    - require:
      - pip: python-pip-install_python_pip

cdh-copy_script_manager_installation_script:
  file.managed:
    - source: salt://cdh/files/cm_setup.py
    - name: {{ scripts_location }}/cm_setup.py

cdh-copy_cm_config:
  file.managed:
    - source: salt://cdh/templates/{{ flavor_cfg.template_file }}.tpl
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
      app_packages_dir: {{ app_packages_dir }}
      data_volumes: {{ data_volumes }}
      pnda_graphite_host: {{ pnda_graphite_host }}

# Create a python configured scripts to call the cm_setup.setup_hadoop function with
# the needed aguments (nodes to install cloudera to)
cdh-create_cloudera_configuration_script:
  file.managed:
    - name: {{ scripts_location}}/cloudera_config.py
    - source: salt://cdh/templates/cloudera_config.py.tpl
    - template: jinja
    - defaults:
        ips: {{ salt['mine.get']('G@hadoop:* and G@pnda_cluster:'+pnda_cluster, 'network.ip_addrs', expr_form='compound') }}
        hadoop_config: {{ salt['mine.get']('G@hadoop:* and G@pnda_cluster:'+pnda_cluster, 'grains.items', expr_form='compound') }}
        cluster_name: {{ pnda_cluster }}
        parcel_repo: {{ cloudera_cdh_repo }}
        parcel_version: {{ cloudera_cdh_version }}

cdh-execute_cloudera_installation_script:
  cmd.run:
    - name: {{ scripts_location }}/venv/bin/python {{ scripts_location }}/cloudera_config.py
    - require:
      - virtualenv: cdh-create_tmp_virtualenv
      - file: cdh-copy_cm_config
      - file: cdh-create_cloudera_configuration_script
      - file: cdh-copy_script_manager_installation_script
