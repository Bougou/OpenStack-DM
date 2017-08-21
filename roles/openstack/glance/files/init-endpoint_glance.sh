#!/bin/bash

function get_id () {
  echo `"$@" | awk '/ id / { print $4 }'`
}


## glance
openstack user create --domain default --password $osdm_user_service_pass glance
openstack role add --project service --user glance admin

##
## clean service/endpoint if exists to avoid duplicated item
openstack endpoint list | grep ' image ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' image ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}

openstack service create --name glance --description "Openstack Image Service" image
openstack endpoint create --region RegionOne image public http://$osdm_os_glance_api_ip:9292
openstack endpoint create --region RegionOne image internal http://$osdm_os_glance_mgmt_ip:9292
openstack endpoint create --region RegionOne image admin http://$osdm_os_glance_mgmt_ip:9292
