description     "Linked-in Gobblin MRv2 application: PNDA pull"

task

umask 022
setuid {{ gobblin_user }}

env JAVA_HOME="/usr/lib/jvm/java-8-oracle/"
env HADOOP_BIN_DIR="{{ hadoop_home_bin }}"

chdir {{ gobblin_directory_name }}

exec bash ./bin/gobblin-compaction.sh --type mr --conf {{ gobblin_job_file }} --logdir /var/log/pnda/gobblin --workdir "{{ gobblin_work_dir }}" --jars $(ls lib/*.jar | tr '\n' ',')
