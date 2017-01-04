description     "Jupyter Hub Daemon"

start on runlevel [2345]
stop on runlevel [!2345]

respawn
respawn limit 10 5

env PYTHON_HOME={{ virtual_env_dir }}

chdir {{ virtual_env_dir }}

exec ${PYTHON_HOME}/bin/jupyterhub --config={{ jupyterhub_config_dir }}/jupyterhub_config.py
