reactor-hadoop_service_start:
  local.state.sls:
    - arg:
      - hdp.service
    - tgt: {{ data['data']['id'] }}
    - timeout: 120
    - queue: True
