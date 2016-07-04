description     "Jupyter Hub Daemon"

start on runlevel [2345]
stop on runlevel [!2345]

respawn
respawn limit 10 5

chdir {{ jupyterhub_config_dir }}

exec jupyterhub
