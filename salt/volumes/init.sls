
{% set volume_partitions_file = '/etc/pnda/disk-config/partitions' %}
{% set volume_mappings_file = '/etc/pnda/disk-config/volume-mappings' %}

{% if salt['file.file_exists' ](volume_partitions_file) %}
  {% set partition_mappings = salt['cmd.shell']('cat ' + volume_partitions_file) %}

  {% for line in partition_mappings.split('\n') %}
    {% set parts = line.split(' ') %}
    {% set device = parts[0] %}
    {% set part_type = parts[1] %}
    {% set partition = parts[2] %}
    {% set start = parts[3] %}
    {% set end = parts[4] %}

    volumes_label-{{ partition }}:
      module.run:
        - name: partition.mklabel
        - device: {{ device }}
        - label_type: {{ part_type }}
        - unless:
          - sudo parted /dev/xvdc print | grep 'Partition Table: {{ part_type }}'

    volumes_partition-{{ partition }}:
      module.run:
        - name: partition.mkpart
        - device: {{ device }}
        - part_type: primary
        - start: {{ start }}
        - end: {{ end }}
        - onlyif:
          - salt-call partition.exists {{ partition }} | grep False
  {% endfor %}
{% endif %}

{% if salt['file.file_exists' ](volume_mappings_file) %}
  {% set volume_mappings = salt['cmd.shell']('cat ' + volume_mappings_file) %}

  {% for line in volume_mappings.split('\n') %}
    {% set parts = line.split(' ') %}
    {% set device = parts[0] %}
    {% set mountpoint = parts[1] %}
    {% set fs_type = parts[2] %}

    volumes-format-{{ device }}:
      blockdev.formatted:
        - name: {{ device }}
        - fs_type: {{ fs_type }}

    volumes-mount-{{ device }}:
      mount.mounted:
        - name: {{ mountpoint }}
        - device: {{ device }}
        - fstype: {{ fs_type }}
        - mkmnt: True
  {% endfor %}
{% endif %}