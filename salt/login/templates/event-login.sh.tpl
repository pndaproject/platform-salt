#!/bin/bash

set -x

if [ $PAM_USER == {{ pnda_user }} ]; then exit; fi
{% raw %}
if [ ${#PAM_USER} -ge 256 ]; then exit; fi
{% endraw %}
GROUP=`id -gn ${PAM_USER}`

sudo salt-call event.send 'user/login' user=${PAM_USER} group=${GROUP}
