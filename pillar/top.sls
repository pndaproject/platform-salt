{{ saltenv }}:
  '*':
    - pnda
    - identity
    - flavors.{{ salt['grains.get']('pnda:flavor', 'standard') }}
    - services
    - env_parameters
    - packages.{{ grains['os'] }}
    - hadoop.hdp
