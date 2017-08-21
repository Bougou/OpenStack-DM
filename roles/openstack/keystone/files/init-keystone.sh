#!/bin/bash

function get_id () {
  echo `"$@" | awk '/ id / { print $4 }'`
}

# domain: default
# user: admin
# role: admin
# service: keystone/identity 
# was already created in keystone bootstrap

# Create Project, User, Role

## Demo
openstack project create --domain default --description "Demo Project" demo
openstack user create --domain default --password $osdm_user_demo_pass demo
openstack role create user
openstack role add --project demo --user demo user

## Service
openstack project create --domain default --description "Service Project" service

## Note: force the script to return true
# It's not permitted to create project/user/role with the same name in the same domain.
# So the above `create` commands will fail they were repeated.
echo