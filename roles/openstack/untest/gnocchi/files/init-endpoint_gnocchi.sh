#!/bin/bash

function get_id () {
  echo `"$@" | awk '/ id / { print $4 }'`
}


## gnocchi
openstack user create --domain default --password $osdm_user_service_pass gnocchi
openstack role add --project service --user gnocchi admin

##
## clean service/endpoint if exists to avoid duplicated item
openstack endpoint list | grep ' metric ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' metric ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}

openstack service create --name gnocchi --description "Openstack Metric Service" metric
openstack endpoint create --region RegionOne metric public http://$osdm_os_gnocchi_api_ip:8041
openstack endpoint create --region RegionOne metric internal http://$osdm_os_gnocchi_mgmt_ip:8041
openstack endpoint create --region RegionOne metric admin http://$osdm_os_gnocchi_mgmt_ip:8041
