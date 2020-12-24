#!/bin/bash

VMNUM="0";
while getopts ":hn:" optname
do
  case "$optname" in
    "h")
      echo "   `basename ${0}`:usage:[-n vm_num]"
      echo "   where vm_num can be one in: [0..31], and the max number of VM is 32."
      exit 1
      ;;
    "n")
      VMNUM=$OPTARG
      ;;
    *)
    # Should not occur
      echo "Unknown error while processing options"
      ;;
  esac
done

ovs-vsctl del-br br0
ovs-vsctl add-br br0 -- set bridge br0 datapath_type=netdev
for((i=0;i<$VMNUM;i++))
do
temp=`expr $i + 1`
if [ `expr $i % 2` -eq 0 ];then
    ovs-vsctl add-port br0 vhost-user-$temp -- set Interface vhost-user-$temp type=dpdkvhostuserclient options:vhost-server-path="/tmp/sock$i"
#    ovs-vsctl set Interface vhost-user-$temp other_config:pmd-rxq-affinity="0:3"
else
    ovs-vsctl add-port br0 vhost-user-$temp -- set Interface vhost-user-$temp type=dpdkvhostuserclient options:vhost-server-path="/tmp/sock$i"
#    ovs-vsctl set Interface vhost-user-$temp other_config:pmd-rxq-affinity="0:18"
fi
ovs-vsctl set Interface vhost-user-$temp other_config:pmd-rxq-affinity="0:2"
done
ovs-vsctl add-port br0 dpdk-p0 -- set Interface dpdk-p0 type=dpdk options:dpdk-devargs=0000:01:00.1
ovs-vsctl set Interface dpdk-p0 other_config:pmd-rxq-affinity="0:3"
ovs-ofctl del-flows br0
dpdkid=`expr $VMNUM + 1`
for((i=0;i<$VMNUM;i++))
do
temp=`expr $i + 1`
tempip=`printf "%02d" $temp`
temphex=`printf "%02x" $temp`
ovs-ofctl add-flow br0 "arp,nw_dst=192.168.1.1$tempip/32,actions=output:$temp"
ovs-ofctl add-flow br0 "ip,nw_dst=192.168.1.1$tempip/32,actions=output:$temp"
ovs-ofctl add-flow br0 "dl_dst=00:00:00:00:00:$temphex,actions=output:$temp"
ovs-ofctl add-flow br0 "in_port=$temp,action:output=$dpdkid"
done
