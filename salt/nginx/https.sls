{% set admin_user = salt['pillar.get']('nginx:admin_user', 'admin') %}
{% set admin_password = salt['pillar.get']('nginx:admin_password', 'admin') %}
{% set certificates_email = salt['pillar.get']('nginx:certificates_email', 'admin') %}

include:
  - nginx

nginx-ssl_req:
  pkg.installed:
    - pkgs:
      - apache2-utils
      - python-openssl

# create user/password
nginx-create_admin_user:
  webutil.user_exists:
    - name: {{ admin_user }}
    - password: {{ admin_password }}
    - htpasswd_file: /etc/nginx/.htpasswd
    - options: d
    - force: true

nginx-create_pki_dir:
  file.directory:
    - name: /etc/pki
    - user: root
    - group: root
    - dir_mode: 755
    - makedirs: True


# create certificaets
nginx-certificates_ca:
   module:
     - run
     - name: tls.create_ca
     - bits: 4096
     - ca_name: nginx
     - days: 3650
     - CN: {{salt['network.interfaces']()['eth0']['inet'][0]['address'] }}
     - emailAddress: {{ certificates_email }}
     - if_missing: /etc/pki/ca_cert.crt


