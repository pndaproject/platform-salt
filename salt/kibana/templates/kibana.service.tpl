[Unit]
Description=kibana service

[Service]
Type=simple
LimitNOFILE=32768
ExecStart={{ installdir }}/bin/kibana
