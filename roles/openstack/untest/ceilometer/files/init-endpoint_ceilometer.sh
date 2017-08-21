#!/bin/bash

function get_id () {
  echo `"$@" | awk '/ id / { print $4 }'`
}


## ceilometer
openstack user create --domain default --password $osdm_user_service_pass ceilometer
openstack role add --project service --user ceilometer admin

##
## clean service/endpoint if exists to avoid duplicated item
openstack endpoint list | grep ' metering ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' metering ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}

openstack service create --name ceilometer --description "Openstack Metering Service" metering
openstack endpoint create --region RegionOne metering public http://$osdm_os_ceilometer_api_ip:8777
openstack endpoint create --region RegionOne metering internal http://$osdm_os_ceilometer_mgmt_ip:8777
openstack endpoint create --region RegionOne metering admin http://$osdm_os_ceilometer_mgmt_ip:8777
