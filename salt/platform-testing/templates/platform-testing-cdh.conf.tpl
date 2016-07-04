description "Platform testing cdh upstart script"
author      "PNDA team"
start on runlevel [2345]
task
exec python -B {{ platform_testing_directory }}/{{platform_testing_package}}/monitor.py --plugin cdh --postjson http://{{ console_hoststring }}/metrics --extra "--cmhost {{ cm_hoststring }} --cmport {{ cm_port }} --cmuser {{ cm_username }} --cmpassword {{ cm_password }}"
