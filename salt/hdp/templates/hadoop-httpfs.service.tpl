[Unit]
Description=HTTPFS

[Service]
Type=simple
User=httpfs
Group=httpfs
UMask=007
TimeoutStopSec=300
Environment=HTTPFS_LOG=/var/log/pnda/httpfs
Environment=HTTPFS_TEMP=/tmp/httpfs
ExecStart=/usr/hdp/current/hadoop-httpfs/sbin/httpfs.sh run
Restart=always
RestartSec=2
