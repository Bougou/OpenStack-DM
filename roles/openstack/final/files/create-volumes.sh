#!/bin/bash

openstack volume create --size 1 --type Capacity admin-volume-1;
openstack server add volume vm-cirros-admin-net1-1 admin-volume-1;

openstack volume create --size 1 --type Capacity admin-volume-2;
openstack server add volume vm-cirros-admin-net1-1 admin-volume-2;

openstack volume create --size 1 --type Capacity admin-volume-3;
openstack volume create --size 1 --type Capacity admin-volume-4;
