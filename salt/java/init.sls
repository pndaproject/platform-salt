{#
   Original code taken from https://github.com/saltstack-formulas/sun-java-formula/
   Slightly modified for PNDA
#}
{%- from 'java/settings.sls' import java with context %}

# require a source_url - there is no default download location for a jdk
{%- if java.source_url is defined %}

{{ java.prefix }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

{{ java.java_home_base }}:
  file.directory:
    - user: root
    - group: root
    - mode: 755
    - makedirs: True

unpack-jdk-tarball:
  cmd.run:
    - name: curl {{ java.dl_opts }} '{{ java.source_url }}' | tar xz --no-same-owner
    - cwd: {{ java.prefix }}
    - unless: test -d {{ java.java_real_home }}
    - require:
      - file: {{ java.prefix }}
      - file: {{ java.java_home_base }}
  alternatives.install:
    - name: java-home-link
    - link: {{ java.java_home }}
    - path: {{ java.java_real_home }}
    - priority: 30

unpack-jdk-tarball-force-alternative:
  alternatives.set:
    - name: java-home-link
    - path: {{ java.java_real_home }}
    - require:
      - alternatives: unpack-jdk-tarball

java-java_alternatives:
  alternatives.install:
    - name: java
    - link: /usr/bin/java
    - path: {{ java.java_real_home }}/bin/java
    - priority: 100

java-java_alternatives-force-alternative:
  alternatives.set:
    - name: java
    - path: {{ java.java_real_home }}/bin/java
    - require:
      - alternatives: java-java_alternatives

java-javac_alternatives:
  alternatives.install:
    - name: javac
    - link: /usr/bin/javac
    - path: {{ java.java_real_home }}/bin/javac
    - priority: 100

java-javac_alternatives-force-alternative:
  alternatives.set:
    - name: javac
    - path: {{ java.java_real_home }}/bin/javac
    - require:
      - alternatives: java-javac_alternatives

java-jar_alternatives:
  alternatives.install:
    - name: jar
    - link: /usr/bin/jar
    - path: {{ java.java_real_home }}/bin/jar
    - priority: 100

java-jar_alternatives-force-alternative:
  alternatives.set:
    - name: jar
    - path: {{ java.java_real_home }}/bin/jar
    - require:
      - alternatives: java-jar_alternatives

{%- endif %}
