zookeeper-zookeeper:
  pkg.installed:
    - pkgs:
      - zookeeper
      - zookeeperd
      - libzookeeper-java

/etc/zookeeper:
  file.directory:
    - mode: 755

/etc/zookeeper/conf:
  file.symlink:
    - target: conf_example
    - force: True

{% set nodes = [] %}
{% include "zookeeper/nodes.sls" %}

/etc/zookeeper/conf/myid:
  file.managed:
    - source: salt://zookeeper/files/templates/zookeeper-myid.tpl
    - template: jinja
    - context:
      nodes:
      {%- for node in nodes %}
        -
          id: {{ node.id }}
          ip: {{ node.ip }}
          fqdn: {{ node.fqdn }}
      {%- endfor %}
    - mode: 644

/etc/zookeeper/conf/zoo.cfg:
  file.managed:
    - source: salt://zookeeper/files/templates/zoo.cfg.tpl
    - template: jinja
    - context:
      nodes:
      {%- for node in nodes %}
        -
          id: {{ node.id }}
          ip: {{ node.ip }}
          fqdn: {{ node.fqdn }}
      {%- endfor %}
    - mode: 644

/etc/zookeeper/conf/environment:
  file.managed:
    - source: salt://zookeeper/files/templates/environment.tpl
    - template: jinja
    - mode: 644

zookeeper-ensure-service-running:
  service.running:
    - name: zookeeper
    - watch:
      - pkg: zookeeper-zookeeper
      - file: /etc/zookeeper/conf/environment
      - file: /etc/zookeeper/conf/zoo.cfg
      - file: /etc/zookeeper/conf/myid
