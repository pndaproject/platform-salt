tickTime=2000
initLimit=20
syncLimit=5
dataDir={{ data_dir }}
clientPort=2181
{%- for node in nodes %}
server.{{ node.id }}={{ node.ip }}:2888:3888
{%- endfor %}
maxClientCnxns=100
cnxTimeout=10
