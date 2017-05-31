#!/bin/bash -v

set -ex
DISTRO=$(cat /etc/*-release|grep ^ID\=|awk -F\= {'print $2'}|sed s/\"//g)
if [ "x$DISTRO" == "xubuntu" ]; then
  export DEBIAN_FRONTEND=noninteractive
  # give the local mirror the first priority 
  sed -i "1ideb $PNDA_MIRROR/mirror_deb/ ./" /etc/apt/sources.list
  wget -O - $PNDA_MIRROR/mirror_deb/pnda.gpg.key | apt-key add -
  (curl -L 'https://archive.cloudera.com/cm5/ubuntu/trusty/amd64/cm/archive.key' | apt-key add - ) && echo 'deb [arch=amd64] https://archive.cloudera.com/cm5/ubuntu/trusty/amd64/cm/ trusty-cm5.9.0 contrib' > /etc/apt/sources.list.d/cloudera-manager.list
  (curl -L 'http://repo.saltstack.com/apt/ubuntu/14.04/amd64/archive/2015.8.11/SALTSTACK-GPG-KEY.pub' | apt-key add - ) && echo 'deb [arch=amd64] http://repo.saltstack.com/apt/ubuntu/14.04/amd64/archive/2015.8.11/ trusty main' > /etc/apt/sources.list.d/saltstack.list
  (curl -L 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key' | apt-key add - ) && echo 'deb [arch=amd64] https://deb.nodesource.com/node_6.x trusty main' > /etc/apt/sources.list.d/nodesource.list
  apt-get update

elif [ "x$DISTRO" == "xrhel" ]; then

if [ "x$YUM_OFFLINE" == "x" ]; then
RPM_EXTRAS=rhui-REGION-rhel-server-extras
RPM_OPTIONAL=rhui-REGION-rhel-server-optional
RPM_EPEL=https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install -y $RPM_EPEL
yum-config-manager --enable $RPM_EXTRAS $RPM_OPTIONAL
yum install -y yum-plugin-priorities yum-utils 
PNDA_REPO=${PNDA_MIRROR/http\:\/\//}
PNDA_REPO=${PNDA_REPO/\//_mirror_rpm}
yum-config-manager --add-repo $PNDA_MIRROR/mirror_rpm
yum-config-manager --setopt="$PNDA_REPO.priority=1" --enable $PNDA_REPO
else
mkdir -p /etc/yum.repos.d.backup/
mv /etc/yum.repos.d/* /etc/yum.repos.d.backup/
yum-config-manager --add-repo $PNDA_MIRROR/mirror_rpm
fi


rpm --import $PNDA_MIRROR/mirror_rpm/RPM-GPG-KEY-redhat-release
rpm --import $PNDA_MIRROR/mirror_rpm/RPM-GPG-KEY-mysql
rpm --import $PNDA_MIRROR/mirror_rpm/RPM-GPG-KEY-cloudera
rpm --import $PNDA_MIRROR/mirror_rpm/RPM-GPG-KEY-EPEL-7
rpm --import $PNDA_MIRROR/mirror_rpm/SALTSTACK-GPG-KEY.pub
rpm --import $PNDA_MIRROR/mirror_rpm/RPM-GPG-KEY-CentOS-7

fi
