[Unit]
Description=elasticsearch service

[Service]
Type=simple
LimitNOFILE=32768
User=elasticsearch
ExecStart={{ installdir }}/bin/elasticsearch -Epath.logs={{ logdir }} -Epath.data={{ datadir }}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target