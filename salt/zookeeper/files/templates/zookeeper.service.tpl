[Unit]
Description=zookeeper centralized coordination service
After=systemd-readahead-collect.service systemd-readahead-replay.service

[Service]
Type=simple
RemainAfterExit=yes
LimitNOFILE=8192
ExecStartPre={{ conf_dir }}/../bin/zookeeper-service-startpre.sh
ExecStart={{ conf_dir }}/../bin/zookeeper-service-start.sh
