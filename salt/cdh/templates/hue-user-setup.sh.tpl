{% set pnda_user = pillar['pnda']['user'] %}
{% set pnda_password = pillar['pnda']['password'] %}
export HUE_CONF_DIR="/var/run/cloudera-scm-agent/process/`ls -alrt /var/run/cloudera-scm-agent/process | grep HUE | tail -1 | awk '{print $9}'`"
export HUE_DATABASE_PASSWORD=hue
export HUE_IGNORE_PASSWORD_SCRIPT_ERRORS=1
cd /opt/cloudera/parcels/CDH/lib/hue/
echo 'checking if user already exists'
build/env/bin/hue  shell <<CHECKUSER
import sys
from django.contrib.auth.models import User

pnda_user = None
try:
    pnda_user = User.objects.get(username='{{ pnda_user }}')
except User.DoesNotExist:
    pnda_user = None

print str(pnda_user)

result_code = 0

if '{{ pnda_user }}' == str(pnda_user):
    result_code = 1

print str(result_code)

sys.exit(result_code)

CHECKUSER
result=$?
echo 'checked if user already exists'
if [ $result -eq 1 ]
then
  echo "User already exists, not creating one or setting its password"
  exit
else
  echo "User not found, will create one"
fi
build/env/bin/hue createsuperuser --username={{ pnda_user }} --noinput --email not@used.com
build/env/bin/hue  shell <<CREATE
from django.contrib.auth.models import User

a = User.objects.get(username='{{ pnda_user }}')
a.set_password('{{ pnda_password }}')
a.save()
CREATE
