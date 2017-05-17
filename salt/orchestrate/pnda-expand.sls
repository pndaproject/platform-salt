{% set pnda_cluster = salt['environ.get']('CLUSTER') %}

cdh-create_cloudera_user:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@cloudera:*'
    - tgt_type: compound
    - sls: cdh.cloudera_user
    - timeout: 120

cdh-install-agents:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@cloudera:*'
    - tgt_type: compound
    - sls: cdh.cloudera-manager-agent
    - timeout: 120

cdh-install_hadoop:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:hadoop_manager'
    - tgt_type: compound
    - sls: cdh.setup_hadoop
    - timeout: 120

cdh-install_platform_libraries:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@cloudera:*'
    - tgt_type: compound
    - sls: pnda.platform-libraries
    - timeout: 120

cdh-install_deployment_manager_keys:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}}'
    - tgt_type: compound
    - sls: deployment-manager.keys
    - timeout: 120
