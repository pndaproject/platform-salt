# Install nodejs, npm
nodejs-install_useful_packages:
  pkg.installed:
    - pkgs:
      - nodejs
      - nodejs-legacy
      - npm

# update the npm version
nodejs-update_npm:
  npm.installed:
    - name: npm
