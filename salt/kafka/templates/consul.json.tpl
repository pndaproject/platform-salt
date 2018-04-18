{
    "service": {
        "id": "broker-{{ salt['grains.get']('broker_id') }}",
        "name": "kafka-ingest",
        "tags": ["{{ salt['grains.get']('broker_id') }}"],
        "address": "{{ public_ip }}",
        "port": {{ ingest_port }}
    }
}