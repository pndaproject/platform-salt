start on runlevel [2345]
stop on runlevel [016]

normal exit 0
respawn
respawn limit unlimited
post-stop exec sleep 2

env HOSTNAME={{host_ip}}
env PORT={{backend_app_port}}
exec node {{app_dir}}/app.js
