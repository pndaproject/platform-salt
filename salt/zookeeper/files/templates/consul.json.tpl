{
    "service": {
        "id": "zookeeper{{myid}}",
        "name": "zookeeper",
        "tags": ["{{myid}}"],
        "address": "{{ internal_ip }}",
        "port": 2181
    },
    "check": {
        "id": "service:zookeeper{{myid}}",
        "name": "Zookeeper health check",
        "ServiceID": "zookeeper{{myid}}",
        "args": ["{{zookeeper_check_script}}"],
        "interval": "60s",
        "timeout": "3s"
    }
}