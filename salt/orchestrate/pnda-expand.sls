{% set pnda_cluster = salt['environ.get']('CLUSTER') %}

cdh-create_cloudera_user:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:cloudera_*'
    - tgt_type: compound
    - sls: cdh.cloudera_user

cdh-install_hadoop:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}} and G@roles:cloudera_manager'
    - tgt_type: compound
    - sls: cdh.setup_hadoop

cdh-install_deployment_manager_keys:
  salt.state:
    - tgt: 'G@pnda_cluster:{{pnda_cluster}}'
    - tgt_type: compound
    - sls: deployment-manager.keys
