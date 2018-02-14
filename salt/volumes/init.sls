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
          - 'grep "Partition Table: {{ part_type }}" <<< "$(parted {{ device }} print)"'

    volumes_partition-{{ partition }}:
      module.run:
        - name: partition.mkpart
        - device: {{ device }}
        - part_type: primary
        - start: {{ start }}
        - end: {{ end }}
        - onlyif:
          - grep False <<< "$(salt-call partition.exists {{ partition }})"
  {% endfor %}
{% endif %}

{% if salt['file.file_exists' ](volume_mappings_file) %}
  {% set volume_mappings = salt['cmd.shell']('cat ' + volume_mappings_file) %}

  {% for line in volume_mappings.split('\n') %}
    {% set parts = line.split(' ') %}
    {% set device = parts[0] %}
    {% set mountpoint = parts[1] %}
    {% set fs_type = parts[2] %}

    {% if fs_type == 'xfs' %}
      {% set mkfs_opts = '-f' %}
    {% else %}
      {% set mkfs_opts = '' %}
    {% endif %}

    {% if fs_type == 'tmpfs' %}

    {% set mount_options = parts[3] %}
    volumes-mount-{{ mountpoint }}:
      mount.mounted:
        - name: {{ mountpoint }}
        - device: {{ device }}
        - fstype: {{ fs_type }}
        - opts: {{ mount_options }}
        - mkmnt: True

    {% else %}
    volumes-wait-{{ device }}:
      cmd.run:
        - name: |
            DISK_READY_RETRIES=0
            DISK_READY_RETRY_LIMIT=60
            DISK_READY_RETRY_INTERVAL=2
            DEVICE={{ device }}
            until [ -b $DEVICE ] || [ $DISK_READY_RETRIES -eq $DISK_READY_RETRY_LIMIT ]; do
                sleep $DISK_READY_RETRY_INTERVAL
                echo waiting for device $DEVICE - retry $(( DISK_READY_RETRIES++ )) of $DISK_READY_RETRY_LIMIT
            done
            [ ! $DISK_READY_RETRIES -eq $DISK_READY_RETRY_LIMIT ]

    volumes-format-{{ device }}:
      cmd.run:
        - name: mkfs -t {{ fs_type  }} {{ mkfs_opts }} {{ device }}
        - unless:
          - 'grep "{{ device }}" <<< "$(cat /etc/fstab)"'

    volumes-mount-{{ device }}:
      mount.mounted:
        - name: {{ mountpoint }}
        - device: {{ device }}
        - fstype: {{ fs_type }}
        - mkmnt: True

    {% endif %}

  {% endfor %}
{% endif %}
