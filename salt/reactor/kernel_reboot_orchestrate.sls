{% set data = salt.pillar.get('event_data') %}
reactor-kernel_reboot_orchestrate-call_system_reboot_state:
  salt.state:
    - tgt: {{ data['data']['id'] }}
    - sls:  
      - reboot.kernel_entry
    - kwarg:
      pillar:
        file_exist: {{ data['data']['file_exist'] }}
    - timeout: 120
    - queue: True
