reactor-create_bastion_host_entry:
  local.state.sls:
    - arg:
      - bastion.hosts
    - tgt: bastion
    - timeout: 120
    - queue: True

