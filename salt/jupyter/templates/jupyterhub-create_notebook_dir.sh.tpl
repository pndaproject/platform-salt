#!/bin/bash

set -x

if [ $PAM_USER == {{ pnda_user }} ]; then exit; fi

GROUP=id -gn $PAM_USER
DIR=/home/$PAM_USER
if [ ! -d $DIR ]; then
    mkdir $DIR
    chmod 0755 $DIR
    chown $PAM_USER:$GROUP $DIR
fi

DIR=$DIR/jupyter_notebooks
if [ ! -d $DIR ]; then
    mkdir $DIR
    ln -s /opt/pnda/jupyter_notebooks $DIR/examples
    chmod -Rh 0755 $DIR
    chown -Rh $PAM_USER:$GROUP $DIR
fi
