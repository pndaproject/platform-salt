start on runlevel [2345]
stop on runlevel [016]

normal exit 0
respawn
respawn limit unlimited
post-stop exec sleep 2

env PYTHON_HOME={{ install_dir }}/deployment_manager/venv

chdir {{ install_dir }}/deployment_manager
exec ${PYTHON_HOME}/bin/python application_summary.py
