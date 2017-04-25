gnuplot-install-gnuplot:
  pkg.installed:
    - name: {{ pillar['gnuplot']['package-name'] }}
    - version: {{ pillar['gnuplot']['version'] }}
    - ignore_epoch: True
