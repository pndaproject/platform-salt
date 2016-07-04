reactor-sync_all:
  local.saltutil.sync_all:
    - tgt: {{ data['id'] }}
