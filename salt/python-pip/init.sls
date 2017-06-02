{% set pip_index_url = pillar['pip']['index_url'] %}

python-pip-purge-first:
  pkg: 
    - purged 
    - name: pip
    
python-pip-install-pip-package:
  pkg.installed:
    - pkgs:
      - {{ pillar['python-pip']['package-name'] }}: {{ pillar['python-pip']['version'] }}
      - {{ pillar['python-dev']['package-name'] }}: {{ pillar['python-dev']['version'] }}
    - ignore_epoch: True
    - require:
      - pkg: python-pip-purge-first
        
python-pip-install_python_pip:
  pip.installed:
    - pkgs:
      - virtualenv == 15.1.0
    - upgrade: True
    - reload_modules: True
    - index_url: {{ pip_index_url }}
    - require:
      - pkg: python-pip-install-pip-package
