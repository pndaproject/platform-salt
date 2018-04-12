###############################################################################
###################### Gobblin MapReduce configurations #######################
###############################################################################

# File system URIs
fs.uri={{ namenode }}
writer.fs.uri=${fs.uri}

job.name=PullFromKafkaMR
job.group=PNDA
job.description=Pulls data from all kafka topics to HDFS

mr.job.max.mappers={{ max_mappers }}

# ==== Kafka Source ====
source.class=gobblin.source.extractor.extract.kafka.KafkaDeserializerSource
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

kafka.deserializer.type=BYTE_ARRAY
kafka.workunit.packer.type=BI_LEVEL

kafka.brokers={{ kafka_brokers|join(",") }}
bootstrap.with.offset=earliest

# ==== Converter ====
converter.classes=gobblin.pnda.PNDARegistryBasedConverter
PNDA.quarantine.dataset.uri={{ quarantine_kite_dataset_uri }}

# ==== Writer ====
writer.builder.class=gobblin.pnda.AvroDataWriterBuilder
writer.codec.type=snappy
writer.destination.type=HDFS
writer.partitioner.class=gobblin.pnda.PNDATimeBasedAvroWriterPartitioner
writer.partition.columns=timestamp
writer.partition.level=hourly
writer.partition.pattern='year='YYYY/'month='MM/'day='dd/'hour='HH
writer.partition.prefix=template

# ==== Publisher ====
data.publisher.type=gobblin.publisher.TimePartitionedDataPublisher
data.publisher.final.dir={{ master_dataset_location }}
data.publisher.appendExtractToFinalDir=false

# ==== Metrics ====
metrics.enabled=true
metrics.reporting.file.enabled=true

# ==== Blacklist topics ====
# Recent Kafka version uses internal __consumer_offsets topic, which we don't
# want to ingest
# Don't ingest the avro.internal.testbot topic as it's only an internal PNDA
# testing topic
topic.blacklist=__consumer_offsets,avro.internal.testbot
