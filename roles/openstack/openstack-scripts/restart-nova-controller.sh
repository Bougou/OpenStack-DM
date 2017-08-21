#!/bin/bash

srv_list="
openstack-nova-os-compute-api
openstack-nova-scheduler
openstack-nova-conductor
openstack-nova-consoleauth
openstack-nova-novncproxy
openstack-nova-metadata-api
"

# openstack-nova-spicehtml5proxy


for srv in $srv_list; do
  echo "Restart service: $srv"
  systemctl restart $srv
done



