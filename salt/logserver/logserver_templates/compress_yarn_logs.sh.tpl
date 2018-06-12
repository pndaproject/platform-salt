#!/bin/bash

/usr/bin/find /var/log/pnda/ -name 'yarn-application_*.log' -type f -mmin +120 |
while read -r i;
do
    filename=${i##*/};
    cd /var/log/pnda;
    if [ -f "yarn-applications_$(date +%m%d%Y).tar.gz" ];
    then
        tar -uf yarn-applications_$(date +%m%d%Y).tar.gz $filename --remove-files;
    else
        tar -cvf yarn-applications_$(date +%m%d%Y).tar.gz $filename --remove-files;
    fi;
done
