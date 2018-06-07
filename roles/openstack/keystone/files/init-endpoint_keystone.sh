#!/bin/bash

function get_id () {
  echo `"$@" | awk '/ id / { print $4 }'`
}

# Create Project, User, Role

## domain is very important.
openstack domain create --description "Default Domain" default

## Admin
openstack project create --domain default --description "Admin Project" admin
openstack user create --domain default --password $osdm_user_admin_pass admin
openstack role create admin
openstack role add --project admin --user admin admin

## Demo
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password $osdm_user_demo_pass demo
openstack role create user
openstack role add --project demo --user demo user

## Service
openstack project create --domain default --description "Service Project" service

##
## clean service/endpoint if exists to avoid duplicated item
openstack endpoint list | grep ' identity ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' identity ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}


## keystone
openstack service create --name keystone --description "Openstack Identity Servcie" identity
#openstack endpoint create --region RegionOne identity public http://$osdm_os_keystone_api_ip:5000/v2.0
#openstack endpoint create --region RegionOne identity internal http://$osdm_os_keystone_mgmt_ip:5000/v2.0
#openstack endpoint create --region RegionOne identity admin http://$osdm_os_keystone_mgmt_ip:35357/v2.0
openstack endpoint create --region RegionOne identity public http://$osdm_os_keystone_api_ip:5000
openstack endpoint create --region RegionOne identity internal http://$osdm_os_keystone_mgmt_ip:5000
openstack endpoint create --region RegionOne identity admin http://$osdm_os_keystone_mgmt_ip:35357
