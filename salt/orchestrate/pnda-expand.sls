{% set pnda_cluster = salt['environ.get']('CLUSTER') %}

{% if pillar['hadoop.distro'] == 'CDH' %}
orchestrate-expand-create_cloudera_user:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@hadoop:* and G@pnda:is_new_node'
    - tgt_type: compound
    - sls: cdh.cloudera_user
    - timeout: 120
    - queue: True

orchestrate-expand-install-agents:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@hadoop:* and G@pnda:is_new_node'
    - tgt_type: compound
    - sls: cdh.cloudera-manager-agent
    - timeout: 120
    - queue: True

orchestrate-expand-install_hadoop:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:hadoop_manager'
    - tgt_type: compound
    - sls: cdh.setup_hadoop
    - timeout: 120
    - queue: True
{% endif %}

{% if pillar['hadoop.distro'] == 'HDP' %}
orchestrate-expand-install_ambari_agents:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@hadoop:* and G@pnda:is_new_node'
    - tgt_type: compound
    - sls: ambari.agent
    - timeout: 120
    - queue: True

orchestrate-expand-install_hdp_hadoop:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:hadoop_manager'
    - tgt_type: compound
    - sls: hdp.setup_hadoop
    - timeout: 120
    - queue: True
{% endif %}

orchestrate-expand-install_platform_libraries:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@hadoop:* and G@pnda:is_new_node'
    - tgt_type: compound
    - sls: pnda.platform-libraries
    - timeout: 120
    - queue: True

orchestrate-expand-install_deployment_manager_keys:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}}'
    - tgt_type: compound
    - sls: deployment-manager.install_keys
    - timeout: 120
    - queue: True

orchestrate-pnda-expand_remove_new_node_markers:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}}'
    - tgt_type: compound
    - sls: orchestrate.remove_new_node_marker
    - timeout: 120
    - queue: True
