{% set flavor_cfg = pillar['pnda_flavor']['states'][sls] %}

{% set scripts_location = '/tmp/pnda-install/' + sls %}
{% set pnda_cluster = salt['pnda.cluster_name']() %}
{% set hdp_p = salt['pillar.get']('hdp', {}) %}

{% set pip_index_url = pillar['pip']['index_url'] %}

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

#TODO - something similar to the cm_setup templates for each flavour

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

hdp-execute_hdp_installation_script:
  cmd.run:
    - name: {{ scripts_location }}/venv/bin/python {{ scripts_location }}/hdp_config.py
    - require:
      - virtualenv: hdp-create_tmp_virtualenv
      # watch the template setup state here
      - file: hdp-create_hdp_configuration_script
      - file: hdp-copy_script_manager_installation_script
