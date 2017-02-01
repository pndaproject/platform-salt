{% if grains['os'] == 'Ubuntu' %}
mysql-connector-install-java-library:
  pkg.installed:
    - name: libmysql-java
{% elif grains['os'] == 'RedHat' %}
mysql-connector-create-dir:
  file.directory:
    - name: '/usr/share/java'

mysql-connector-install-java-library:
  cmd.run:
    - name: curl http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.25/mysql-connector-java-5.1.25.jar > /usr/share/java/mysql-connector-java.jar
{% endif %}