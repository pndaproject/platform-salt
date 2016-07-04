{%- from 'kafka/settings.sls' import kafka with context %}
{% set install_dir = '/opt/pnda' %}

kafka-kafka:
  group.present:
    - name: kafka
  user.present:
    - name: kafka
    - gid_from_name: True
    - groups:
      - kafka

kafka-install-kafka-dist:
  cmd.run:
    - name: curl -L '{{ kafka.source_url }}' | tar xz
    - cwd: {{ install_dir }}
    - unless: test -d {{ kafka.real_home }}/config
  alternatives.install:
    - name: kafka-home-link
    - link: {{ kafka.prefix }}
    - path: {{ kafka.real_home }}
    - priority: 30

kafka-force-alternative:
  alternatives.set:
    - name: kafka-home-link
    - path: {{ kafka.real_home }}
    - require:
      - alternatives: kafka-install-kafka-dist

# fix permissions
{{ kafka.real_home }}:
  file.directory:
    - user: kafka
    - group: kafka
    - recurse:
      - user
      - group
