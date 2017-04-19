# Install nodejs, npm
nodejs-install_useful_packages:
  pkg.installed:
    - name: {{ pillar['nodejs']['package-name'] }}
    - version: {{ pillar['nodejs']['version'] }}
    - ignore_epoch: True
