#!/bin/bash

function get_id () {
  echo `"$@" | awk '/ id / { print $4 }'`
}


## nova
openstack user create --domain default --password $osdm_user_service_pass nova
openstack role add --project service --user nova admin


##
## clean service/endpoint if exists to avoid duplicated item
openstack endpoint list | grep ' compute ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' compute ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}


openstack service create --name nova  --description "OpenStack Compute Service" compute

# legacy v2
#openstack endpoint create --region RegionOne compute public http://$osdm_os_nova_api_ip:8774/v2/%\(tenant_id\)s
#openstack endpoint create --region RegionOne compute internal http://$osdm_os_nova_mgmt_ip:8774/v2/%\(tenant_id\)s
#openstack endpoint create --region RegionOne compute admin http://$osdm_os_nova_mgmt_ip:8774/v2/%\(tenant_id\)s

openstack endpoint create --region RegionOne compute public http://$osdm_os_nova_api_ip:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute internal http://$osdm_os_nova_mgmt_ip:8774/v2.1/%\(tenant_id\)s
openstack endpoint create --region RegionOne compute admin http://$osdm_os_nova_mgmt_ip:8774/v2.1/%\(tenant_id\)s



# create placement user
openstack user create --domain default --password $osdm_user_service_pass placement
openstack role add --project service --user placement admin

##
## clean service/endpoint if exists to avoid duplicated item
openstack endpoint list | grep ' placement ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' placement ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}


# placement service
openstack service create --name placement --description "OpenStack Placement Service" placement

## placement endpoint
openstack endpoint create --region RegionOne placement public http://$osdm_os_nova_api_ip:8778
openstack endpoint create --region RegionOne placement internal http://$osdm_os_nova_mgmt_ip:8778
openstack endpoint create --region RegionOne placement admin http://$osdm_os_nova_mgmt_ip:8778
