{% set extra_mirror = salt['pillar.get']('extra:mirror', '') %}

{% if extra_mirror == '' %}
# Specify version 6 of nodejs, latest LTS
nodejs-v6-setup:
  cmd.run:
{% if grains['os'] == 'Ubuntu' %}
    - name: curl -sL 'https://deb.nodesource.com/setup_6.x' | sudo -E bash -
{% elif grains['os'] == 'RedHat' %}
    - name: curl --silent --location https://rpm.nodesource.com/setup_6.x | sudo -E bash -
{% endif %}
{% endif %}

# Install nodejs, npm
nodejs-install_useful_packages:
  pkg.installed:
    - pkgs:
      - nodejs
{% if extra_mirror == '' %}
    - require:
      - cmd: nodejs-v6-setup
{% endif %}
