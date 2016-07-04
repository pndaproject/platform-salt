{#
   Original code taken from https://github.com/saltstack-formulas/sun-java-formula/
   Slightly modified for PNDA
#}

{%- from 'java/settings.sls' import java with context %}

jdk-config:
  file.managed:
    - name: /etc/profile.d/java.sh
    - source: salt://java/java.sh
    - template: jinja
    - mode: 644
    - user: root
    - group: root
    - context:
      java_home: {{ java.java_home }}
