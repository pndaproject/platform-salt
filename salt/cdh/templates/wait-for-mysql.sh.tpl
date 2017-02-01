mysql_result=1
num_tries=30
while [ $mysql_result -ne 0 ] && [ $num_tries -gt 0 ]
do
  echo "Checking mysql connectivity ($num_tries remaining)..."
  mysql -h {{ cmdb_host }} -uroot -p{{ mysql_root_password }} <<EOF
  show databases;
EOF
  mysql_result=$?
  if [ $mysql_result -ne 0 ]; then
    sleep 5
    num_tries=$(($num_tries-1))
  fi
done
exit $mysql_result