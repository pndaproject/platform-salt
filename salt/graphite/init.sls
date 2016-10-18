# based on http://graphite-api.readthedocs.io/en/latest/deployment.html#nginx-uwsgi

include:
  - python-pip

graphite-reqs:
  pkg.installed:
    - refresh: True
    - pkgs:
      - build-essential
      - python-dev
      - nginx
      - uwsgi
      - uwsgi-plugin-python
      - libcairo2-dev

libffi-dev:
  pkg.installed

libapache2-mod-wsgi:
  pkg.installed

install-graphite-api:
  pip.installed:
    - pkgs:
      - cairocffi == 0.6
      - graphite-api == 1.1.3

graphite-carbon:
  pkg.installed

configure_carbon_default:
  file.managed:
    - name: /etc/default/graphite-carbon
    - source: salt://graphite/files/graphite-carbon

configure_carbon:
  file.managed:
    - name: /etc/carbon/carbon.conf
    - source: salt://graphite/files/carbon.conf

configure_nginx:
  file.managed:
    - name: /etc/nginx/sites-available/graphite.conf
    - source: salt://graphite/files/graphite.conf

enable_nginx:
  file.symlink:
    - name: /etc/nginx/sites-enabled/graphite.conf
    - target: /etc/nginx/sites-available/graphite.conf

configure_uwsgi:
  file.managed:
    - name: /etc/uwsgi/apps-available/graphite-api.ini
    - source: salt://graphite/files/graphite-api.ini

enable_uwsgi:
  file.symlink:
    - name: /etc/uwsgi/apps-enabled/graphite-api.ini
    - target: /etc/uwsgi/apps-available/graphite-api.ini

configure_graphite_yaml:
  file.managed:
    - name: /etc/graphite-api.yaml
    - source: salt://graphite/files/graphite-api.yaml

configure_storage_schemas:
  file.managed:
    - name: /etc/carbon/storage-schemas.conf
    - source: salt://graphite/files/storage-schemas.conf

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
    - watch:
      - file: configure_nginx
      - file: enable_nginx

ensure_uwsgi_running:
  service.running:
    - name: uwsgi
    - enable: True
    - watch:
      - file: configure_uwsgi
      - file: enable_uwsgi
