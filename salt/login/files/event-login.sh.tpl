#!/bin/bash

set -x

if [ $PAM_USER == {{ pnda_user }} ]; then exit; fi
if [ ${#PAM_USER} -ge 256 ]; then exit; fi

GROUP=`id -gn ${PAM_USER}`

sudo salt-call event.send 'user/login' user=${PAM_USER} group=${GROUP}
