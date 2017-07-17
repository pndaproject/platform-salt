{
  "hadoop_distro": "{{hadoop_distro}}",
  "clustername": "{{clustername}}",
  "edge_node": "{{ edge_node }}",
  "user_interfaces": [
    {
      "name": "Hadoop Cluster Manager",
      "link": "{{ hadoop_manager_link }}"
    },
    {
      "name": "Kafka Manager",
      "link": "{{ kafka_manager_link }}"
    },
    {
      "name": "OpenTSDB",
      "link": "{{ opentsdb_link }}"
    },
    {
      "name": "Grafana",
      "link": "{{ grafana_link }}"
    },
    {
      "name": "PNDA logserver",
      "link": "{{ kibana_link }}"
    },
    {
      "name": "Jupyter",
      "link": "{{ jupyter_link }}"
    }
  ],
  "frontend": {
    "version": "{{ frontend_version }}"
  },
  "backend": {
    "data-manager": {
      "version": "{{data_manager_version}}",
      "host": "{{data_manager_host}}", "port": "{{data_manager_port}}"
    }
  },
  "disable_ldap_login": true
}
