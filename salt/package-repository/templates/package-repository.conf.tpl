start on runlevel [2345]
stop on runlevel [016]

normal exit 0
respawn
respawn limit unlimited
post-stop exec sleep 2

env PYTHON_HOME={{install_dir }}/package_repository/venv

chdir {{ install_dir }}/package_repository
exec ${PYTHON_HOME}/bin/python package_repository_rest_server.py
