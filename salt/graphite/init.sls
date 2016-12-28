# based on http://graphite-api.readthedocs.io/en/latest/deployment.html#nginx-uwsgi
{% set virtual_env_dir = '/opt/pnda/graphite-api' %}

include:
  - python-pip

graphite-reqs:
  pkg.installed:
    - refresh: True
    - pkgs:
      - python-dev
      - build-essential
      - libcairo2-dev
      - libffi-dev
      - graphite-carbon
      - nginx
      - uwsgi
      - uwsgi-plugin-python

graphite-create-virtualenv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - requirements: salt://graphite/files/requirements.txt
    - require:
      - pip: python-pip-install_python_pip

configure_carbon_default:
  file.managed:
    - name: /etc/default/graphite-carbon
    - source: salt://graphite/files/graphite-carbon
    - require:
      - pkg: graphite-reqs

configure_carbon:
  file.managed:
    - name: /etc/carbon/carbon.conf
    - source: salt://graphite/files/carbon.conf
    - require:
      - pkg: graphite-reqs

configure_nginx:
  file.managed:
    - name: /etc/nginx/sites-available/graphite.conf
    - source: salt://graphite/files/graphite.conf
    - require:
      - pkg: graphite-reqs

enable_nginx:
  file.symlink:
    - name: /etc/nginx/sites-enabled/graphite.conf
    - target: /etc/nginx/sites-available/graphite.conf
    - require:
      - file: configure_nginx

configure_uwsgi:
  file.managed:
    - name: /etc/uwsgi/apps-available/graphite-api.ini
    - source: salt://graphite/templates/graphite-api.ini
    - template: jinja
    - context:
      virtual_env_dir: {{ virtual_env_dir }}
    - require:
      - pkg: graphite-reqs

enable_uwsgi:
  file.symlink:
    - name: /etc/uwsgi/apps-enabled/graphite-api.ini
    - target: /etc/uwsgi/apps-available/graphite-api.ini
    - require:
      - virtualenv: graphite-create-virtualenv

configure_graphite_yaml:
  file.managed:
    - name: /etc/graphite-api.yaml
    - source: salt://graphite/files/graphite-api.yaml

configure_storage_schemas:
  file.managed:
    - name: /etc/carbon/storage-schemas.conf
    - source: salt://graphite/files/storage-schemas.conf
    - require:
      - pkg: graphite-reqs

/srv/graphite:
  file.directory:
    - user: root
    - group: root
    - mode: 777
    - makedirs: True

ensure_carbon_running:
  service.running:
    - name: carbon-cache
    - enable: True
    - watch:
      - file: configure_carbon
      - file: configure_storage_schemas

ensure_nginx_running:
  service.running:
    - name: nginx
    - enable: True
    - require:
      - file: configure_graphite_yaml
      - file: enable_uwsgi
    - watch:
      - file: configure_nginx
      - file: enable_nginx

ensure_uwsgi_running:
  service.running:
    - name: uwsgi
    - enable: True
    - require:
      - service: ensure_nginx_running
    - watch:
      - file: configure_uwsgi
      - file: enable_uwsgi
