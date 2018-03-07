#!/bin/sh
service {{ ntp_service }} stop || echo already stopped
ntpdate {{ ntp_servers|join(" ") }}
service {{ ntp_service }} start
