[Install]
WantedBy=multi-user.target

[Unit]
Description=HAProxy service
After=network.target

[Service]
Environment="CONFIG={{ haproxy_config_dir}}/haproxy.cfg" "PIDFILE=/var/run/haproxy.pid"
ExecStartPre=/usr/sbin/haproxy -f $CONFIG -c -q
ExecStartPre=/bin/echo ${CONFIG} ${PIDFILE}
ExecStart=/usr/sbin/haproxy -f $CONFIG -p $PIDFILE
ExecReload=/usr/sbin/haproxy -f $CONFIG -c -q
ExecReload=/bin/kill -USR2 $MAINPID
KillMode=mixed
Restart=always
RestartSec=5
Type=forking
