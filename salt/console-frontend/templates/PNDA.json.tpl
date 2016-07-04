{
  "clustername": "{{clustername}}",
  "edge_node": "{{ edge_node }}",
  "user_interfaces": [
    {
      "name": "Cloudera Manager",
      "link": "http://{{ cloudera_manager_ip }}:7180"
    },
    {
      "name": "Kafka Manager",
      "link": "http://{{ kafka_manager_ip }}:9000/clusters/{{ clustername }}"
    },
    {
      "name": "OpenTSDB",
      "link": "http://{{ opentsdb }}:4242"
    },
    {
      "name": "Grafana",
      "link": "http://{{ grafana }}:3000"
    },
    {
      "name": "PNDA logserver",
      "link": "http://{{ kibana }}:5601"
    },
    {
      "name": "Jupyter",
      "link": "http://{{ jupyter_ip }}:8000"
    }
  ],
  "frontend": {
    "version": "{{frontend_version}}"
  },
  "backend": {
    "data-manager": {
      "version": "{{data_manager_version}}",
      "host": "{{data_manager_host}}", "port": "{{data_manager_port}}"
    }
  },
  "disable_ldap_login": true
}
