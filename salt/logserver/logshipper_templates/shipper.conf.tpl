{%- set logdest = salt['pnda.ip_addresses']('logserver')[0] -%}
input {
   file {
          path => ["/var/log/upstart/kafka.log",
                  "/var/log/pnda/kafka/server.log",
                  "/var/log/pnda/kafka/controller.log"]
          add_field => {"source" => "kafka"}
          sincedb_path => "{{ install_dir }}/logstash/sincedb/db"
   }
   file {
          path => ["/var/log/pnda/zookeeper/zookeeper.log"]
          add_field => {"source" => "zookeeper"}
          sincedb_path => "{{ install_dir }}/logstash/sincedb/db"
   }
   file {
          path => ["/var/log/salt/minion",
                   "/tmp/cm_setup.log"]
          add_field => {"source" => "provisioning"}
          sincedb_path => "{{ install_dir }}/logstash/sincedb/db"
   }
   file {
          path => ["/var/log/upstart/deployment-manager.log"]
          add_field => {"source" => "deployment-manager"}
          sincedb_path => "{{ install_dir }}/logstash/sincedb/db"
   }
   file {
          path => ["/var/log/upstart/package-repository.log"]
          add_field => {"source" => "package-repository"}
          sincedb_path => "{{ install_dir }}/logstash/sincedb/db"
   }
   file {
          path => ["/var/log/opentsdb/opentsdb.log"]
          add_field => {"source" => "opentsdb"}
          sincedb_path => "{{ install_dir }}/logstash/sincedb/db"
   }
   file {
          path => ["/var/log/grafana/grafana.log"]
          add_field => {"source" => "grafana"}
          sincedb_path => "{{ install_dir }}/logstash/sincedb/db"
   }
   file {
          path => ["/var/log/upstart/jupyterhub.log"]
          add_field => {"source" => "jupyter"}
          sincedb_path => "{{ install_dir }}/logstash/sincedb/db"
   }
   file {
          path => ["/var/log/pnda/hadoop-yarn/container/application_*/container_*/stdout",
                   "/var/log/pnda/hadoop-yarn/container/application_*/container_*/stderr",
                   "/var/log/pnda/hadoop-yarn/container/application_*/container_*/syslog",
                   "/var/log/pnda/hadoop-yarn/container/application_*/container_*/spark.log"]
          add_field => {"source" => "yarn"}
          sincedb_path => "{{ install_dir }}/logstash/sincedb/db"
   }
   file {
          path => ["/var/log/pnda/hadoop/*/*.log",
                  "/var/log/pnda/hadoop/*/*.log.out"]
          add_field => {"source" => "hadoop"}
          sincedb_path => "{{ install_dir }}/logstash/sincedb/db"
   }
}

output {
   redis { host => "{{ logdest }}" data_type => "channel" key => "logstash-%{+yyyy.MM.dd.HH}" }
}
