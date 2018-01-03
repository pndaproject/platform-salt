
start on runlevel [2345]
stop on runlevel [016]

normal exit 0
respawn
respawn limit unlimited
post-stop exec sleep 2

env SPARK_HOME={{ spark_home }}
env HADOOP_CONF_DIR={{ hadoop_conf_dir }}


chdir {{ install_dir }}
exec su -s /bin/sh -c 'exec "$0" "$@"' pnda -- ./bin/livy-server
