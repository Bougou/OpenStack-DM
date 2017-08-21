#!/bin/bash

function get_id () {
  echo `"$@" | awk '/ id / { print $4 }'`
}


## ironic
openstack user create --domain default --password $osdm_user_service_pass ironic
openstack role add --project service --user ironic admin

##
## clean service/endpoint if exists to avoid duplicated item
openstack endpoint list | grep ' baremetal ' | awk '{print $2}' | \
  xargs -I {} openstack endpoint delete {}
openstack service list | grep ' baremetal ' | awk '{print $2}' | \
  xargs -I {} openstack service delete {}


openstack service create --name ironic --description "OpenStack Ironic baremetal provisioning service" baremetal
openstack endpoint create --region RegionOne baremetal public http://$osdm_os_ironic_api_ip:6385
openstack endpoint create --region RegionOne baremetal internal http://$osdm_os_ironic_mgmt_ip:6385
openstack endpoint create --region RegionOne baremetal admin http://$osdm_os_ironic_mgmt_ip:6385

# These role name is defined in ironic code: /usr/lib/python2.7/site-packages/ironic/common/policy.py
openstack role create baremetal_admin
openstack role create baremetal_observer

openstack project create baremetal
openstack user create --domain default --project-domain default --project baremetal --password baremetal baremetal
openstack role add --user-domain default --project-domain default --project baremetal --user baremetal baremetal_observer