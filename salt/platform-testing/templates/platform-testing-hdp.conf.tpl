description "Platform testing hdp upstart script"
author      "PNDA team"
start on runlevel [2345]
task
env PYTHON_HOME={{ platform_testing_directory }}/{{platform_testing_package}}/venv
exec ${PYTHON_HOME}/bin/python {{ platform_testing_directory }}/{{platform_testing_package}}/monitor.py --plugin hdp --postjson http://{{ console_hoststring }}/metrics --extra "--cmhost {{ cm_hoststring }} --cmport {{ cm_port }} --cmuser {{ cm_username }} --cmpassword {{ cm_password }} --cluster_name {{ cluster_name }}"
