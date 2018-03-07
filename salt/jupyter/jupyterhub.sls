{% set packages_server = pillar['packages_server']['base_uri'] %}
{% set pnda_home_directory = pillar['pnda']['homedir'] %}
{% set virtual_env_dir = pnda_home_directory + '/jupyter' %}
{% set pip_index_url = pillar['pip']['index_url'] %}
{% set proxy_version = pillar['jupyterproxy']['release_version'] %}
{% set proxy_package = 'jupyterproxy-' + proxy_version + '.tar.gz' %}

{% set jupyterhub_config_dir = '/etc/jupyterhub' %}

include:
  - nodejs

jupyterhub-install:
  pip.installed:
    - requirements: salt://jupyter/files/requirements-jupyterhub.txt
    - index_url: {{ pip_index_url }}
    - bin_env: {{ virtual_env_dir }}
    - require:
      - virtualenv: jupyter-create-venv

jupyterhub-create_config_dir:
  file.directory:
    - name: {{ jupyterhub_config_dir }}
    - require:
      - pip: jupyterhub-install

{% if salt.file.file_exists(jupyterhub_config_dir+'/jupyterhub.cert') %}
{% set old_cert_string = salt.cmd.shell("sed -e '/-----END CERTIFICATE-----/q' "+jupyterhub_config_dir+'/jupyterhub.cert') %}
{% set old_cn = salt.x509.read_certificate(old_cert_string)['Subject']['CN'] %}
{% else %}
{% set old_cn = None %}
{% endif %}

{% if pillar.jupyter is defined and pillar.jupyter.cert is defined and pillar.jupyter.key is defined %}
{% set jupyterhub_ssl_cert = jupyterhub_config_dir+'/jupyterhub.cert' %}
{% set jupyterhub_ssl_key = jupyterhub_config_dir+'/jupyterhub.key' %}

jupyterhub-create_ssl_cert:
  file.managed:
    - name: {{ jupyterhub_config_dir }}/jupyterhub.cert
    - contents_pillar: jupyter:cert
    - user: root
    - group: pnda
    - mode: 640

jupyterhub-create_ssl_key:
  file.managed:
    - name: {{ jupyterhub_config_dir }}/jupyterhub.key
    - contents_pillar: jupyter:key
    - user: root
    - group: pnda
    - mode: 640

{% set cert = salt.pillar.get('jupyter:cert') %}
{% set new_cert_string = salt.cmd.shell("echo '"+ cert +"' | sed -e '/-----END CERTIFICATE-----/q'") %}
{% set new_cn = salt.x509.read_certificate(new_cert_string)['Subject']['CN'] %}

{% if old_cn != new_cn %}
jupyterhub-event_cn:
  event.send:
    - name: 'fqdn/updated/jupyter'
    - data:
      ssl: True
      old_cn: {{ old_cn }}
      new_cn: {{ new_cn }}
      ip_addr: {{ salt.pnda.get_hosts_for_role('jupyter')[0] }}
{% endif %}

{% else %}
{% set jupyterhub_ssl_cert = '\'\'' %}
{% set jupyterhub_ssl_key = '\'\'' %}
jupyterhub-event_cn:
  event.send:
    - name: 'fqdn/updated/jupyter'
    - data:
      ssl: False
      old_cn: {{ old_cn }}
      new_cn: None
{% endif %}

jupyterhub-create_configuration:
  file.managed:
    - name: {{ jupyterhub_config_dir }}/jupyterhub_config.py
    - source: salt://jupyter/templates/jupyterhub_config.py.tpl
    - template: jinja
    - context:
      virtual_env_dir: {{ virtual_env_dir }}
      jupyterhub_ssl_cert: {{ jupyterhub_ssl_cert }}
      jupyterhub_ssl_key: {{ jupyterhub_ssl_key }}
    - require:
      - file: jupyterhub-create_config_dir

jupyterhub-create_log_dir:
  file.directory:
    - name: /var/log/pnda/jupyter
    - makedirs: True

jupyterhub-proxy-dl-and-extract:
  archive.extracted:
    - name: {{ pnda_home_directory }}
    - source: {{ packages_server }}/{{ proxy_package }}
    - source_hash: {{ packages_server }}/{{ proxy_package }}.sha512.txt
    - archive_format: tar
    - if_missing: {{ pnda_home_directory }}/configurable-http-proxy-{{ proxy_version }}

jupyterhub-proxy-rebuild:
  cmd.run:
    - name: npm rebuild > /dev/null
    - cwd: {{ pnda_home_directory }}/configurable-http-proxy-{{ proxy_version }}

jupyterhub-install-proxy-modules:
  file.symlink:
    - target: {{ pnda_home_directory }}/configurable-http-proxy-{{ proxy_version }}
    - name: {{ pnda_home_directory }}/nodejs/lib/node_modules/configurable-http-proxy

jupyterhub-install-proxy-command:
  file.symlink:
    - target: {{ pnda_home_directory }}/nodejs/lib/node_modules/configurable-http-proxy/bin/configurable-http-proxy
    - name: /usr/bin/configurable-http-proxy

# set up service script
jupyterhub-copy_service:
  file.managed:
{% if grains['os'] == 'Ubuntu' %}
    - source: salt://jupyter/templates/jupyterhub.conf.tpl
    - name: /etc/init/jupyterhub.conf
{% elif grains['os'] in ('RedHat', 'CentOS') %}
    - name: /usr/lib/systemd/system/jupyterhub.service
    - source: salt://jupyter/templates/jupyterhub.service.tpl
{%- endif %}
    - mode: 644
    - template: jinja
    - context:
      jupyterhub_config_dir: {{ jupyterhub_config_dir }}
      virtual_env_dir: {{ virtual_env_dir }}

{% if grains['os'] in ('RedHat', 'CentOS') %}
jupyterhub-systemctl_reload:
  cmd.run:
    - name: /bin/systemctl daemon-reload; /bin/systemctl enable jupyterhub
{%- endif %}

jupyterhub-service_started:
  cmd.run:
    - name: 'service jupyterhub stop || echo already stopped; service jupyterhub start'
    - require:
      - pip: jupyterhub-install
      - file: jupyterhub-copy_service
      - file: jupyterhub-install-proxy-command

