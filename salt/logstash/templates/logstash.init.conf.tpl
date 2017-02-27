# Ubuntu upstart file at /etc/init/logstash-cluster.conf

description "logstash-cluster service"

start on runlevel [2345]
stop on [!12345]

respawn
respawn limit 2 5

umask 007

kill timeout 300

setuid logstash
setgid logstash

script
	chdir {{ installdir }}

	exec bin/logstash -l {{logdir}} -f {{confpath}} --path.data {{datadir}}
end script