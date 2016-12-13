# Specify version 6 of nodejs, latest LTS
nodejs-v6-setup:
  cmd.run:
    - name: curl -sL 'https://deb.nodesource.com/setup_6.x' | sudo -E bash -

# Install nodejs, npm
nodejs-install_useful_packages:
  pkg.installed:
    - pkgs:
      - nodejs
      - nodejs-legacy
      - npm
    - require:
      - cmd: nodejs-v6-setup

# update the npm version
nodejs-update_npm:
  npm.installed:
    - name: npm
    - require:
      - cmd: nodejs-v6-setup
