description "JMXProxy service"

limit nofile 32768 32768

start on runlevel [2345]
stop on [!12345]

respawn
respawn limit 2 5

umask 007

kill timeout 300

exec java -jar {{ install_dir }}/jmxproxy.jar server {{ install_dir }}/etc/jmxproxy.yaml
