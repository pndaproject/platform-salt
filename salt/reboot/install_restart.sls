{% set app_directory_name = '/restart' %}
{% set install_dir = pillar['pnda']['homedir'] + app_directory_name %}

include:
  - python-pip

{% if grains['os'] == 'RedHat' %}
reboot-install_deps:
  pkg.installed:
    - pkgs:
      - at
{% endif %}

reboot-create-venv:
  virtualenv.managed:
    - name: {{ install_dir }}
    - requirements: salt://reboot/files/requirements.txt
    - require:
      - pip: python-pip-install_python_pip

reboot-copy_app:
  file.managed:
    - name: {{ install_dir }}/pnda_restart.py
    - source: salt://reboot/files/pnda_restart.py
    - makedirs: True
    - require:
      - virtualenv: reboot-create-venv

reboot-copy_config:
  file.managed:
    - name: {{ install_dir }}/properties.json
    - source: salt://reboot/templates/properties.json.tpl
    - template: jinja
    - require:
      - virtualenv: reboot-create-venv

{% if grains['os'] == 'Ubuntu' %}
reboot-copy_upstart:
  file.managed:
    - name: /etc/init/pnda-restart.conf
    - source: salt://reboot/templates/pnda-restart.conf.tpl
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}
{% elif grains['os'] == 'RedHat' %}
reboot-copy_systemd:
  file.managed:
    - name: /usr/lib/systemd/system/pnda-restart.service
    - source: salt://reboot/templates/pnda-restart.service.tpl
    - template: jinja
    - defaults:
        install_dir: {{ install_dir }}
{% endif %}
