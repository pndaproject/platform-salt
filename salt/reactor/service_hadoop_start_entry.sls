reactor-hadoop_service_start:
  local.state.sls:
    - arg:
      - reactor.service_hadoop_start
    - tgt: {{ data['data']['id'] }}
    - timeout: 120
    - queue: True
