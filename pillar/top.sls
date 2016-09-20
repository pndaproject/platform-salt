{{ saltenv }}:
  '*':
    - pnda
    - flavors.{{ salt['grains.get']('pnda:flavor', 'standard') }}
    - services
    - env_parameters
