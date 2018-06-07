#!/bin/bash

function get_id () {
  echo `"$@" | awk '/ id / { print $4 }'`
}


## cloudkitty
openstack user create --domain default --password $osdm_user_service_pass cloudkitty
openstack role add --project service --user cloudkitty admin

openstack role create rating

##
## clean service/endpoint if exists to avoid duplicated item
openstack endpoint list | grep ' rating ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' rating ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}

openstack service create --name cloudkitty --description "OpenStack Rating Service" rating

openstack endpoint create --region RegionOne rating public http://$osdm_os_cloudkitty_api_ip:8889
openstack endpoint create --region RegionOne rating internal http://$osdm_os_cloudkitty_mgmt_ip:8889
openstack endpoint create --region RegionOne rating admin http://$osdm_os_cloudkitty_mgmt_ip:8889
