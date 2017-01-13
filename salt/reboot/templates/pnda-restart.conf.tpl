task

chdir {{ install_dir }}
env PYTHON_HOME={{ install_dir }}
exec ${PYTHON_HOME}/bin/python {{ install_dir }}/pnda_restart.py
