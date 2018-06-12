reactor-jupyter_user_login:
  local.state.apply:
    - tgt: 'G@roles:jupyter'
    - expr_form: compound
    - arg:
      - jupyter.user_login
    - kwarg:
        pillar:
          user: {{ data['data']['user'] }}
          group: {{ data['data']['group'] }}
        queue: True

reactor-hdfs_user_login:
  local.state.apply:
    - tgt: 'G@roles:hadoop_edge'
    - expr_form: compound
    - arg:
      - master-dataset.user_login
    - kwarg:
        pillar:
          user: {{ data['data']['user'] }}
          group: {{ data['data']['group'] }}
        queue: True

