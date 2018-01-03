#!/bin/bash

set -x

if [ $PAM_USER == {{ pnda_user }} ]; then exit; fi

DIR=/home/$PAM_USER
if [ ! -d $DIR ]; then
    mkdir $DIR
    chmod 0755 $DIR
    chown $PAM_USER: $DIR
fi

DIR=$DIR/jupyter_notebooks
if [ ! -d $DIR ]; then
    mkdir $DIR
    ln -s /opt/pnda/jupyter_notebooks $DIR/examples
    chmod -R 0755 $DIR
    chown -R $PAM_USER: $DIR
fi
