orchestrate_remove_marker:
  grains.absent:
    - name: 'pnda:is_new_node'
    - destructive: True