[Unit]
Description=HTTPFS

[Service]
Type=forking
User=httpfs
Group=hadoop
RuntimeDirectory=httpfs
WorkingDirectory=-/run/httpfs
Restart=always
RestartSec=2

Environment=CONF_DIR=/usr/hdp/current/hadoop-httpfs/../hadoop/conf

Environment=HTTPFS_RUN=/run/httpfs
Environment=HTTPFS_LOG=/var/log/pnda/httpfs
Environment=HTTPFS_USER=httpfs
Environment=HTTPFS_CONFIG=/usr/hdp/current/hadoop-httpfs/../hadoop/conf
Environment=HTTPFS_TEMP=/run/httpfs
Environment=HTTPFS_SLEEP_TIME=5

Environment=CATALINA_PID=/run/httpfs/httpfs.pid
Environment=CATALINA_TMPDIR=/run/httpfs

ExecStart=/usr/hdp/current/hadoop-httpfs/sbin/httpfs.sh start httpfs httpfs
ExecStop=/usr/hdp/current/hadoop-httpfs/sbin/httpfs.sh stop httpfs httpfs

PIDFile=/run/httpfs/httpfs.pid

[Install]
WantedBy=multi-user.target
