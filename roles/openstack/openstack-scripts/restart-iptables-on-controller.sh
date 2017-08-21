#!/bin/bash

srv_list="
iptables
openstack-nova-api
neutron-dhcp-agent
neutron-l3-agent
neutron-openvswitch-agent
"

for srv in $srv_list; do
  echo "Restart service: $srv"
  systemctl restart $srv
done
