#!/bin/bash

function get_id () {
  echo `"$@" | awk '/ id / { print $4 }'`
}


## cinder
openstack user create --domain default --password $osdm_user_service_pass cinder
openstack role add --project service --user cinder admin

##
## clean service/endpoint if exists to avoid duplicated item
openstack endpoint list | grep ' volume ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' volume ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}

openstack endpoint list | grep ' volumev2 ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' volumev2 ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}

openstack endpoint list | grep ' volumev3 ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' volumev3 ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}

openstack service create --name cinder --description "OpenStack Block Storage Service" volume
openstack endpoint create --region RegionOne volume public http://$osdm_os_cinder_api_ip:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume internal http://$osdm_os_cinder_mgmt_ip:8776/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne volume admin http://$osdm_os_cinder_mgmt_ip:8776/v1/%\(tenant_id\)s

##  Also register a service and endpoint for version 2 of the Block Storage Service API
openstack service create --name cinderv2 --description "OpenStack Block Storage Service V2" volumev2
openstack endpoint create --region RegionOne volumev2 public http://$osdm_os_cinder_api_ip:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://$osdm_os_cinder_mgmt_ip:8776/v2/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://$osdm_os_cinder_mgmt_ip:8776/v2/%\(tenant_id\)s

##  Also register a service and endpoint for version 3 of the Block Storage Service API
openstack service create --name cinderv3 --description "OpenStack Block Storage Service V3" volumev3
openstack endpoint create --region RegionOne volumev3 public http://$osdm_os_cinder_api_ip:8776/v3/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 internal http://$osdm_os_cinder_mgmt_ip:8776/v3/%\(tenant_id\)s
openstack endpoint create --region RegionOne volumev3 admin http://$osdm_os_cinder_mgmt_ip:8776/v3/%\(tenant_id\)s
