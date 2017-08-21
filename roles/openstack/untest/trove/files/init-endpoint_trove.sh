#!/bin/bash

function get_id () {
  echo `"$@" | awk '/ id / { print $4 }'`
}


## trove
openstack user create --domain default --password $osdm_user_service_pass trove
openstack role add --project service --user trove admin

##
## clean service/endpoint if exists to avoid duplicated item
openstack endpoint list | grep ' database ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' database ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}

openstack service create --name trove --description "OpenStack Database Service" database
openstack endpoint create --region RegionOne database public http://$osdm_os_trove_api_ip:8779/v1.0/%\(tenant_id\)s
openstack endpoint create --region RegionOne database internal http://$osdm_os_trove_mgmt_ip:8779/v1.0/%\(tenant_id\)s
openstack endpoint create --region RegionOne database admin http://$osdm_os_trove_mgmt_ip:8779/v1.0/%\(tenant_id\)s
