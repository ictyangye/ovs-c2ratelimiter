ovs-vsctl del-br br0
ovs-vsctl add-br br0 -- set bridge br0 datapath_type=netdev
ovs-vsctl add-port br0 vhost-user-1 -- set Interface vhost-user-1 type=dpdkvhostuserclient options:vhost-server-path="/tmp/sock0"
ovs-vsctl add-port br0 eth0
ovs-ofctl del-flows br0
ovs-ofctl add-flow br0 "arp,nw_dst=10.21.0.226/32,actions=output:1"
ovs-ofctl add-flow br0 "ip,nw_dst=10.21.0.226/32,actions=output:1"
ovs-ofctl add-flow br0 "dl_dst=00:00:00:00:00:01,actions=output:1"
ovs-ofctl add-flow br0 "in_port=1,action:output=2"
