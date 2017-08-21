#!/bin/bash

function get_id () {
  echo `"$@" | awk '/ id / { print $4 }'`
}


## neutron
openstack user create --domain default --password $osdm_user_service_pass neutron
openstack role add --project service --user neutron admin

##
## clean service/endpoint if exists to avoid duplicated item
openstack endpoint list | grep ' network ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' network ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}

openstack service create --name neutron --description "OpenStack Networking Service" network
openstack endpoint create --region RegionOne network public http://$osdm_os_neutron_api_ip:9696
openstack endpoint create --region RegionOne network internal http://$osdm_os_neutron_mgmt_ip:9696
openstack endpoint create --region RegionOne network admin http://$osdm_os_neutron_mgmt_ip:9696
