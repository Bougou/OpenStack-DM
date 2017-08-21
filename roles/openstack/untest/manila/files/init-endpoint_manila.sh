#!/bin/bash

function get_id () {
  echo `"$@" | awk '/ id / { print $4 }'`
}


## manila
openstack user create --domain default --password $osdm_user_service_pass manila
openstack role add --project service --user manila admin

##
## clean service/endpoint if exists to avoid duplicated item
openstack endpoint list | grep ' share ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' share ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}

openstack endpoint list | grep ' sharev2 ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' sharev2 ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}


openstack service create --name manila --description "OpenStack Shared File Systems" share
openstack endpoint create --region RegionOne share public http://$osdm_os_manila_api_ip:8786/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne share internal http://$osdm_os_manila_mgmt_ip:8786/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne share admin http://$osdm_os_manila_mgmt_ip:8786/v1/%\(tenant_id\)s

openstack service create --name manilav2 --description "OpenStack Shared File Systems" sharev2
openstack endpoint create --region RegionOne sharev2 public http://$osdm_os_manila_api_ip:8786/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne sharev2 internal http://$osdm_os_manila_mgmt_ip:8786/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne sharev2 admin http://$osdm_os_manila_mgmt_ip:8786/v2/%\(tenant_id\)s
