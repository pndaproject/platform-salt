#!/bin/bash -v

set -ex

chmod 400 /tmp/git.pem
echo "Host $PACKAGES_SERVER_IP" >> /root/.ssh/config
echo "  IdentityFile /tmp/git.pem" >> /root/.ssh/config
echo "  StrictHostKeyChecking no" >> /root/.ssh/config

apt-get update
apt-get -y install xfsprogs

echo "Mounting xvdc for logs"
umount /dev/xvdc || echo 'not mounted'
mkfs.xfs -f /dev/xvdc
mkdir -p /var/log/panda
sed -i "/xvdc/d" /etc/fstab
echo "/dev/xvdc /var/log/panda auto defaults,nobootwait,comment=cloudconfig 0 2" >> /etc/fstab

DISKS="xvdd xvde xvdf"
DISK_IDX=0
for DISK in $DISKS; do
   echo $DISK
   if [ -b /dev/$DISK ];
   then
      echo "Mounting $DISK"
      umount /dev/$DISK || echo 'not mounted'
      mkfs.xfs -f /dev/$DISK
      mkdir -p /data$DISK_IDX
      sed -i "/$DISK/d" /etc/fstab
      echo "/dev/$DISK /data$DISK_IDX auto defaults,nobootwait,comment=cloudconfig 0 2" >> /etc/fstab
      DISK_IDX=$((DISK_IDX+1))
   fi
done
cat /etc/fstab
mount -a

export DEBIAN_FRONTEND=noninteractive
apt-get update && apt-get -y install python-pip
apt-get -y install python-git
wget -O install_salt.sh https://bootstrap.saltstack.com
sh install_salt.sh -D -U -M stable 2015.8.10
apt-get -y install unzip

cat << EOF > /etc/salt/master
## specific PNDA saltmaster config
auto_accept: True      # auto accept minion key on new minion provisioning

fileserver_backend:
  - roots
  - minion

file_roots:
  base:
    - /srv/salt/platform-salt/salt

pillar_roots:
  base:
    - /srv/salt/platform-salt/pillar

# Do not merge top.sls files across multiple environments
top_file_merging_strategy: same

# To autoload new created modules, states add and remove salt keys,
# update bastion /etc/hosts file automatically ... add the following reactor configuration
reactor:
  - 'minion_start':
    - salt://reactor/sync_all.sls
  - 'salt/cloud/*/created':
    - salt://reactor/create_bastion_host_entry.sls
  - 'salt/cloud/*/destroying':
    - salt://reactor/delete_bastion_host_entry.sls
## end of specific PNDA saltmaster config
file_recv: True

failhard: True
EOF

mkdir -p /srv/salt
cd /srv/salt


if [ "x$PLATFORM_GIT_REPO_URI" != "x" ]; then
  git clone -q --branch $PLATFORM_GIT_BRANCH $PLATFORM_GIT_REPO_URI
elif [ "x$PLATFORM_URI" != "x" ] ; then
  mkdir -p /srv/salt/platform-salt && cd /srv/salt/platform-salt && \
  wget -q -O - $PLATFORM_URI | tar -zvxf - --strip=1 && ls -al && \
  cd -
else
  exit 2
fi

cat << EOF >> /srv/salt/platform-salt/pillar/env_parameters.sls
os_user: $OS_USER
keystone.user: ''
keystone.password: ''
keystone.tenant: ''
keystone.auth_url: ''
keystone.region_name: ''
aws.region: '$AWS_REGION'
aws.key: '$S3_ACCESS_KEY_ID'
aws.secret: '$S3_SECRET_ACCESS_KEY'
pnda.apps_container: '$PNDA_APPS_CONTAINER'
pnda.apps_folder: '$PNDA_APPS_FOLDER'
pnda.archive_container: '$PNDA_ARCHIVE_CONTAINER'
pnda.archive_type: 's3a'
pnda.archive_service: ''
EOF

if [ "x$JAVA_MIRROR" != "x" ] ; then
cat << EOF >> /srv/salt/platform-salt/pillar/env_parameters.sls
java:
  source_url: '$JAVA_MIRROR'
EOF
fi

if [ "x$CLOUDERA_MIRROR" != "x" ] ; then
cat << EOF >> /srv/salt/platform-salt/pillar/env_parameters.sls
cloudera:
  parcel_repo: '$CLOUDERA_MIRROR'
EOF
fi

if [ "x$ANACONDA_MIRROR" != "x" ] ; then
cat << EOF >> /srv/salt/platform-salt/pillar/env_parameters.sls
anaconda:
  parcel_version: "4.0.0"
  parcel_repo: '$ANACONDA_MIRROR'
EOF
fi

if [ "x$PACKAGES_SERVER_URI" != "x" ] ; then
cat << EOF >> /srv/salt/platform-salt/pillar/env_parameters.sls
packages_server:
  base_uri: $PACKAGES_SERVER_URI
EOF
fi


echo $PNDA_CLUSTER-saltmaster > /etc/hostname
hostname $PNDA_CLUSTER-saltmaster

restart salt-master
