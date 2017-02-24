[Unit]
Description=elasticsearch service

[Service]
Type=simple
User=elasticsearch
Group=elasticsearch
UMask=007
TimeoutStopSec=300
LimitNOFILE=65536
ExecStart={{ installdir }}/bin/elasticsearch -Edefault.path.logs={{ logdir }} -Edefault.path.data={{ datadir }}
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target