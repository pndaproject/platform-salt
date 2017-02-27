[Unit]
Description=elasticsearch service

[Service]
Type=simple
LimitNOFILE=32768
ExecStart={{ installdir }}/bin/elasticsearch -Des.default.config={{ defaultconfig }} -Des.default.path.logs={{ logdir }} -Des.default.path.data={{ datadir }} -Des.default.path.work={{ workdir }} -Des.default.path.conf={{ confdir }}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target