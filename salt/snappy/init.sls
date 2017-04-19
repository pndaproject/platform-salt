snappy-install-snappy:
  pkg.installed:
    - name: {{ pillar['snappy']['package-name'] }}
    - version: {{ pillar['snappy']['version'] }}
    - ignore_epoch: True
