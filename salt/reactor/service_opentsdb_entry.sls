reactor-openTsdb_service_start:
  local.state.sls:
    - arg:
      - opentsdb.service
    - tgt: {{ data['data']['id'] }}
