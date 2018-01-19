reactor-update_fqdn_entry:
  local.state.apply:
    - tgt: 'G@roles:bastion'
    - expr_form: compound
    - arg:
      - bastion.fqdn_update
    - kwarg:
        pillar:
          old_cn: {{ data['data']['old_cn'] }}
          new_cn: {{ data['data']['new_cn'] }}
          ip_addr: {{ data['data']['ip_addr'] }}
