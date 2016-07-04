description     "Linked-in Gobblin MRv2 application: PNDA pull"

task

umask 022
setuid {{ gobblin_user }}

env JAVA_HOME="/usr/lib/jvm/java-8-oracle/"
env HADOOP_BIN_DIR="/opt/cloudera/parcels/CDH/bin"

chdir {{ gobblin_directory_name }}

exec bash ./bin/gobblin-mapreduce.sh --conf /home/{{ gobblin_user }}/configs/mr.pull --workdir "{{ gobblin_work_dir }}" --jars $(ls lib/*.jar | grep -v -E '(hive-exec|hadoop)' | tr '\n' ',')
