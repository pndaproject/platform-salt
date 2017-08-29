invoke_kernel_reboot_orchestrate_file:
  runner.state.orchestrate:
    - mods: reactor.kernel_reboot_orchestrate
    - kwarg:
      pillar:
        event_data: {{ data|json() }}
