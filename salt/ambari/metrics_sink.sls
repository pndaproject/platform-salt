ambari-legacy-metrics-hadoop-sink-pkg:
  pkg.installed:
    - name: {{ pillar['ambari-legacy-metrics-hadoop-sink']['package-name'] }}
    - version: {{ pillar['ambari-legacy-metrics-hadoop-sink']['version'] }}
    - ignore_epoch: True

ambari-metrics-hadoop-sink-pkg:
  pkg.installed:
    - name: {{ pillar['ambari-metrics-hadoop-sink']['package-name'] }}
    - version: {{ pillar['ambari-metrics-hadoop-sink']['version'] }}
    - ignore_epoch: True
