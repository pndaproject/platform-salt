{%- set selector = 'G@pnda_cluster:' + salt['grains.get']('pnda_cluster') + ' and G@roles:zookeeper' %}
{%- set zk_interfaces = salt['mine.get'](selector, 'network.interfaces', 'compound') %}
{%- set listen_iface = flavor_cfg.get('listen_iface', 'eth0') %}

{%- set c = cycler(*range(1, 255)) %}
{%- for server, addrs in zk_interfaces.items() %}
{%- do nodes.append({'id': c.next(), 'ip': addrs[listen_iface]['inet'][0]['address'] , 'fqdn': server }) %}
{%- endfor %}
