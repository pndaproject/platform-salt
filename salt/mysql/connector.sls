{% set pnda_mirror = pillar['pnda_mirror']['base_url'] %}
{% set misc_packages_path = pillar['pnda_mirror']['misc_packages_path'] %}
{% set mirror_location = pnda_mirror + misc_packages_path %}

{% set connector_package = 'mysql-connector-java-5.1.25.jar' %}
{% set connector_url = mirror_location + connector_package %}

mysql-connector-create-dir:
  file.directory:
    - name: '/usr/share/java'

mysql-connector-install-java-library:
  cmd.run:
    - name: curl {{ connector_url }} > /usr/share/java/mysql-connector-java.jar
