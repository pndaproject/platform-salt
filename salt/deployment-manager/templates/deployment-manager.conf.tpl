start on runlevel [2345]
stop on runlevel [016]

normal exit 0
respawn
respawn limit unlimited
post-stop exec sleep 2

chdir {{ install_dir }}/deployment_manager
exec python app.py
