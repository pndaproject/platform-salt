gateway:
  knox:
    port: 8443
    base: gateway
    topologies:
      - name: pnda
        services:
          console:
            context: console
          ambari:
            context: ambari
          httpfs:
            context: webhdfs
          yarn:
            context: yarn
          flink:
            context: flinkhistory
      - name: pndaops
        services:
          kibana:
            context: kibana
          kafka-manager:
            context: kafkamanager
  haproxy:
    base: ''
    port: 8444
    topologies:
     - name: ''
       services:
         jupyter:
           context: jupyter
         grafana:
           context: grafana
