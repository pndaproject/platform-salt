#!/usr/bin/expect
set timeout 120
set secret [lindex $argv 0]
spawn {{ knox_bin_path }}/knoxcli.sh create-master --force
sleep 5
expect {
"*secret:" {send "$secret\n"}
}
expect {
"*again:" {send "$secret\n"}
}
sleep 5
send "exit\r"
