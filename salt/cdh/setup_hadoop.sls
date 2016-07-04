{% set scripts_location = '/tmp' %}
{% set ssh_prv_key = scripts_location + '/cloudera.pem' %}
{% set pnda_cluster = salt['pnda.cluster_name']() %}
{% set cloudera_p = salt['pillar.get']('cloudera', {}) %}

{% set keystone_user = salt['pillar.get']('keystone.user', "") %}
{% set keystone_password = salt['pillar.get']('keystone.password', "") %}
{% set keystone_tenant = salt['pillar.get']('keystone.tenant', "") %}
{% set keystone_auth_url = salt['pillar.get']('keystone.auth_url', "") + '/tokens' %}
{% set region = salt['pillar.get']('keystone.region_name', "") %}
{% set mysql_host = salt['pnda.ip_addresses']('cloudera_oozie_database')[0] %}
{% set aws_key = salt['pillar.get']('aws.key', '') %}
{% set aws_secret_key = salt['pillar.get']('aws.secret', '') %}

include:
  - .cloudera-api

cdh-copy_script_manager_installation_script:
  file.managed:
    - source: salt://cdh/files/cm_setup.py
    - name: {{ scripts_location }}/cm_setup.py

cdh-copy_cm_config_standard:
  file.managed:
    - source: salt://cdh/templates/cfg_standard.py.tpl
    - name: {{ scripts_location }}/cfg_standard.py
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

cdh-copy_install_sharedlib:
  file.managed:
    - source: salt://cdh/files/install_sharedlib.py
    - name: {{ scripts_location }}/install_sharedlib.py

# Create a python configured scripts to call the cm_setup.setup_hadoop function with
# the needed aguments (nodes to install cloudera to)
cdh-create_cloudera_configuration_script:
  file.managed:
    - name: {{ scripts_location}}/cloudera_config.py
    - source: salt://cdh/templates/cloudera_config.py.tpl
    - template: jinja
    - defaults:
        ips: {{ salt['mine.get']('G@roles:cloudera_* and G@pnda_cluster:'+pnda_cluster, 'network.ip_addrs', expr_form='compound') }}
        cloudera_config: {{ salt['mine.get']('G@roles:cloudera_* and G@pnda_cluster:'+pnda_cluster, 'grains.items', expr_form='compound') }}
        private_key_filename: {{ ssh_prv_key }}
        cluster_name: {{ pnda_cluster }}
        parcel_repo: {{ cloudera_p.get('parcel_repo', '') }}
        parcel_version: {{ cloudera_p.get('parcel_version', '') }}

cdh-execute_cloudera_installation_script:
  cmd.run:
    - name: python {{ scripts_location }}/cloudera_config.py
