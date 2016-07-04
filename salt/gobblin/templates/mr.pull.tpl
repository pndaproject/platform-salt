###############################################################################
###################### Gobblin MapReduce configurations #######################
###############################################################################

# File system URIs
fs.uri=hdfs://{{ namenode }}:8020
writer.fs.uri=${fs.uri}

job.name=PullFromKafkaMR
job.group=PNDA
job.description=Pulls data from all kafka topics to HDFS

# ==== Kafka Source ====
source.class=gobblin.source.extractor.extract.kafka.KafkaSimpleSource
source.timezone=UTC
source.schema={"namespace": "pnda.entity",                 \
               "type": "record",                            \
               "name": "event",                             \
               "fields": [                                  \
                   {"name": "timestamp", "type": "long"},   \
                   {"name": "src",       "type": "string"}, \
                   {"name": "host_ip",   "type": "string"}, \
                   {"name": "rawdata",   "type": "bytes"}   \
               ]                                            \
              }

kafka.brokers={{ kafka_brokers|join(",") }}
bootstrap.with.offset=earliest

# ==== Converter ====
converter.classes=gobblin.pnda.PNDAConverter
PNDA.quarantine.dataset.uri={{ quarantine_kite_dataset_uri }}


# ==== Writer ====
writer.builder.class=gobblin.pnda.PNDAKiteWriterBuilder
kite.writer.dataset.uri={{ kite_dataset_uri }}

# ==== Metrics ====
metrics.enabled=true
metrics.reporting.file.enabled=true
