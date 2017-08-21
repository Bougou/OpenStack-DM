#!/bin/bash

function get_id () {
  echo `"$@" | awk '/ id / { print $4 }'`
}


## heat
openstack user create --domain default --password $osdm_user_service_pass heat
openstack role add --project service --user heat admin

openstack service create --name heat --description "Orchestration" orchestration
openstack service create --name heat-cfn --description "Orchestration" cloudformation

openstack endpoint create --region RegionOne orchestration public http://$osdm_os_heat_api_ip:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne orchestration internal http://$osdm_os_heat_mgmt_ip:8004/v1/%\(tenant_id\)s
openstack endpoint create --region RegionOne orchestration admin http://$osdm_os_heat_mgmt_ip:8004/v1/%\(tenant_id\)s

openstack endpoint create --region RegionOne cloudformation public http://$osdm_os_heat_api_ip:8000/v1
openstack endpoint create --region RegionOne cloudformation internal http://$osdm_os_heat_mgmt_ip:8000/v1
openstack endpoint create --region RegionOne cloudformation admin http://$osdm_os_heat_mgmt_ip:8000/v1


# Orchestration requires additional information in the Identity service to manage stacks.
openstack domain create --description "Stack projects and users" heat
openstack user create --domain heat --password $osdm_user_service_pass heat_domain_admin
openstack role add --domain heat --user heat_domain_admin admin

# You must add the heat_stack_owner role to each user that manages stacks.
openstack role create heat_stack_owner

#openstack role add --project admin --user admin heat_stack_owner
openstack role add --project demo --user demo heat_stack_owner

# The Orchestration service automatically assigns the heat_stack_user role to users that it creates during stack deployment.
# By default, this role restricts API operations. To avoid conflicts, do not add this role to users with the heat_stack_owner role.
# You must add the `heat_stack_owner` role to each user that manages stacks.
openstack role create heat_stack_user
