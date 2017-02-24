[Unit]
Description=logstash-cluster service

[Service]
Type=simple
User=logstash
Group=logstash
UMask=007
TimeoutStopSec=300
ExecStart={{ installdir }}/bin/logstash -l {{logdir}} -f {{confpath}} --path.data {{datadir}}
Restart=always
RestartSec=2

[Install]
WantedBy=multi-user.target