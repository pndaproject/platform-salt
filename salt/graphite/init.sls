# based on http://graphite-api.readthedocs.io/en/latest/deployment.html#nginx-uwsgi
{% set virtual_env_dir = '/opt/pnda/graphite-api' %}
{% set pip_index_url = salt['pillar.get']('pip:index_url', 'https://pypi.python.org/simple/') %}

include:
  - python-pip

{% if grains['os'] == 'Ubuntu' %}
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
      - libcairo2-dev
libffi-dev:
  pkg.installed
libapache2-mod-wsgi:
  pkg.installed
graphite-carbon:
  pkg.installed
{% elif grains['os'] == 'RedHat' %}
Development Tools:
  pkg.group_installed
libffi-devel:
  pkg.installed
uwsgi:
  pkg.installed
python-carbon:
  pkg.installed
_graphite:
  user.present
{% endif %}

install-graphite-api:
  pip.installed:
    - pkgs:
      - cairocffi == 0.6
      - graphite-api == 1.1.3
    - index_url: {{ pip_index_url }}

graphite-create-virtualenv:
  virtualenv.managed:
    - name: {{ virtual_env_dir }}
    - requirements: salt://graphite/files/requirements.txt
    - python: python2
    - index_url: {{ pip_index_url }}
    - require:
      - pip: python-pip-install_python_pip

configure_carbon_default:
  file.managed:
    - name: /etc/default/graphite-carbon
    - source: salt://graphite/files/graphite-carbon
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkg: graphite-reqs
{% endif %}

configure_carbon:
  file.managed:
    - name: /etc/carbon/carbon.conf
    - source: salt://graphite/files/carbon.conf
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkg: graphite-reqs
{% endif %}

{% if grains['os'] == 'Ubuntu' %}
configure_nginx:
  file.managed:
    - name: /etc/nginx/sites-available/graphite.conf
    - source: salt://graphite/files/graphite.conf
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkg: graphite-reqs
{% endif %}

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
{% elif grains['os'] == 'RedHat' %}
selinux_graphite:
  cmd.run:
    - name: semanage port -a -t http_port_t -p tcp 8013
    - unless: semanage port -l | grep 8013
enable_nginx:
    file.managed:
      - name: /etc/nginx/conf.d/graphite.conf
      - source: salt://graphite/files/graphite.conf
enable_uwsgi:
  file.managed:
    - name: /etc/uwsgi.d/graphite-api.ini
    - source: salt://graphite/templates/graphite-api.ini
{% endif %}
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
{% if grains['os'] == 'Ubuntu' %}
    - require:
      - pkg: graphite-reqs
{% endif %}

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
{% if grains['os'] == 'Ubuntu' %}
      - file: configure_nginx
{% endif %}
      - file: enable_nginx

ensure_uwsgi_running:
  service.running:
    - name: uwsgi
    - enable: True
    - require:
      - service: ensure_nginx_running
    - watch:
{% if grains['os'] == 'Ubuntu' %}
      - file: configure_uwsgi
{% endif %}
      - file: enable_uwsgi