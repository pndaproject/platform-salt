{% set pnda_user = pillar['pnda']['user'] %}
{% set pnda_password = pillar['pnda']['password'] %}
export HUE_CONF_DIR="/var/run/cloudera-scm-agent/process/`ls -alrt /var/run/cloudera-scm-agent/process | grep HUE | tail -1 | awk '{print $9}'`"
export HUE_DATABASE_PASSWORD=hue
export HUE_IGNORE_PASSWORD_SCRIPT_ERRORS=1 
cd /opt/cloudera/parcels/CDH/lib/hue/
build/env/bin/hue createsuperuser --username={{ pnda_user }} --noinput --email not@used.com
build/env/bin/hue  shell <<CREATE
from django.contrib.auth.models import User
 
a = User.objects.get(username='{{ pnda_user }}')
a.set_password('{{ pnda_password }}')
a.save()
CREATE
