{
  "name": "default",
  "description": "default quick links configuration",
  "configuration": {
    "protocol":
    {
      "type":"http"
    },

    "links": [
      {
        "name": "hbase_master_ui",
        "label": "HBase Master UI",
        "url":"{{ service_proxy_url }}/master-status",
        "requires_user_name": "false",
        "port":{
          "http_property": "hbase.master.info.port",
          "http_default_port": "60010",
          "https_property": "hbase.master.info.port",
          "https_default_port": "60443",
          "regex": "",
          "site": "hbase-site"
        }
      },
      {
        "name": "hbase_logs",
        "label": "HBase Logs",
        "url":"{{ service_proxy_url }}/logs",
        "requires_user_name": "false",
        "port":{
          "http_property": "hbase.master.info.port",
          "http_default_port": "60010",
          "https_property": "hbase.master.info.port",
          "https_default_port": "60443",
          "regex": "",
          "site": "hbase-site"
        }
      },
      {
        "name": "zookeeper_info",
        "label": "Zookeeper Info",
        "url":"{{ service_proxy_url }}/zk.jsp",
        "requires_user_name": "false",
        "port":{
          "http_property": "hbase.master.info.port",
          "http_default_port": "60010",
          "https_property": "hbase.master.info.port",
          "https_default_port": "60443",
          "regex": "",
          "site": "hbase-site"
        }
      },
      {
        "name": "hbase_master_jmx",
        "label": "HBase Master JMX",
        "url":"{{ service_proxy_url }}/jmx",
        "requires_user_name": "false",
        "port":{
          "http_property": "hbase.master.info.port",
          "http_default_port": "60010",
          "https_property": "hbase.master.info.port",
          "https_default_port": "60443",
          "regex": "",
          "site": "hbase-site"
        }
      },
      {
        "name": "debug_dump",
        "label": "Debug Dump",
        "url":"{{ service_proxy_url }}/dump",
        "requires_user_name": "false",
        "port":{
          "http_property": "hbase.master.info.port",
          "http_default_port": "60010",
          "https_property": "hbase.master.info.port",
          "https_default_port": "60443",
          "regex": "",
          "site": "hbase-site"
        }
      },
      {
        "name": "thread_stacks",
        "label": "Thread Stacks",
        "url":"{{ service_proxy_url }}/stacks",
        "requires_user_name": "false",
        "port":{
          "http_property": "hbase.master.info.port",
          "http_default_port": "60010",
          "https_property": "hbase.master.info.port",
          "https_default_port": "60443",
          "regex": "",
          "site": "hbase-site"
        }
      }
    ]
  }
}
