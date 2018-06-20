[Unit]
Description=Grafana instance
Documentation=http://docs.grafana.org
Wants=network-online.target
After=network-online.target

[Service]
EnvironmentFile=/etc/sysconfig/grafana-server
User={{ user }}
Group={{ group }}
Type=simple
Restart=on-failure
WorkingDirectory=/usr/share/grafana
ExecStartPre=sudo /opt/pnda/utils/register-service.sh grafana-internal {{ grafana_port }}
ExecStart=/usr/sbin/grafana-server                                \
                            --config=${CONF_FILE}                 \
                            --pidfile=${PID_FILE}                 \
                            cfg:default.paths.logs=${LOG_DIR}     \
                            cfg:default.paths.data=${DATA_DIR}    \
                            cfg:default.paths.plugins=${PLUGINS_DIR}
LimitNOFILE=10000
TimeoutStopSec=20

[Install]
WantedBy=multi-user.target