#!/bin/bash

function get_id () {
  echo `"$@" | awk '/ id / { print $4 }'`
}


## aodh
openstack user create --domain default --password $osdm_user_service_pass aodh
openstack role add --project service --user aodh admin

##
## clean service/endpoint if exists to avoid duplicated item
openstack endpoint list | grep ' alarming ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' alarming ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}

openstack service create --name aodh --description "OpenStack Alarming Service" alarming
openstack endpoint create --region RegionOne alarming public http://$osdm_os_aodh_api_ip:8042/
openstack endpoint create --region RegionOne alarming internal http://$osdm_os_aodh_mgmt_ip:8042/
openstack endpoint create --region RegionOne alarming admin http://$osdm_os_aodh_mgmt_ip:8042/
