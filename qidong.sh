#!/bin/bash
export RTE_SDK=/home/yangye/vhost-user/dpdk-stable-17.11.9
export LD_LIBRARY_PATH=/home/yangye/vhost-user/dpdk-stable-17.11.9/x86_64-native-linuxapp-gcc/lib/
ovsdb-server --remote=punix:/usr/local/var/run/openvswitch/db.sock --remote=db:Open_vSwitch,Open_vSwitch,manager_options --pidfile --detach --log-file
ovs-vsctl --no-wait init
export DB_SOCK=/usr/local/var/run/openvswitch/db.sock
ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-init=true
#ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-extra="--base-virtaddr 7ffe00000000 --file-prefix=spdk1"
#ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-extra="--proc-type=secondary"
ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem="1024,0"
#ovs-vsctl --no-wait set Open_vSwitch . other_config:pmd-cpu-mask=0xc000c
ovs-vsctl --no-wait set Open_vSwitch . other_config:pmd-cpu-mask=0xc
#ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-extra=""
#ovs-vsctl --no-wait set Open_vSwitch . other_config:dpdk-socket-mem=""
ovs-vswitchd --pidfile --detach --log-file

