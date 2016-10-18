#!/bin/bash -v

set -e

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
wget -O install_salt.sh https://bootstrap.saltstack.com
sh install_salt.sh -D -U stable 2015.8.11

cat > /etc/salt/minion <<EOF
master: $PNDA_SALTMASTER_IP
EOF

cat >> /etc/salt/grains <<EOF
pnda:
  flavor: $PNDA_FLAVOR
EOF
