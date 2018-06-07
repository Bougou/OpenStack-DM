#!/bin/bash

# osdm_ft_ext_range
# osdm_ft_ext_gateway
# osdm_ft_ext_pool_start
# osdm_ft_ext_pool_end
# osdm_ft_dns1
# osdm_ft_dns2
# osdm_ft_admin_net1_range
# osdm_ft_admin_net1_gateway
# osdm_ft_admin_net2_range
# osdm_ft_admin_net2_gateway

## ExternalNet
##

openstack network create \
    --share \
    --external \
    --provider-network-type flat \
    --provider-physical-network physnet-ext \
    ExtNetFlat


openstack subnet create \
    --ip-version 4 \
    --network ExtNetFlat \
    --subnet-range $osdm_ft_ext_range \
    --gateway $osdm_ft_ext_gateway \
    --allocation-pool start=$osdm_ft_ext_pool_start,end=$osdm_ft_ext_pool_end \
    --dns-nameserver $osdm_ft_dns1 \
    --dns-nameserver $osdm_ft_dns2 \
    ExtNetFlat-v4-Subnet-1


## AdminNet - 1
##

openstack network create \
    --provider-network-type vxlan \
    AdminNet1

openstack subnet create \
    --ip-version 4 \
    --network AdminNet1 \
    --subnet-range $osdm_ft_admin_net1_range \
    --gateway $osdm_ft_admin_net1_gateway \
    AdminNet1-v4-Subnet-1


## AdminNet - 2
##

openstack network create \
    --provider-network-type vxlan \
    AdminNet2

openstack subnet create \
    --ip-version 4 \
    --network AdminNet2 \
    --subnet-range $osdm_ft_admin_net2_range \
    --gateway $osdm_ft_admin_net2_gateway \
    --dns-nameserver $osdm_ft_dns1 \
    --dns-nameserver $osdm_ft_dns2 \
    AdminNet2-v4-Subnet-1


## AdminRouter
##

openstack router create AdminRouter-1
openstack router create AdminRouter-2

openstack router add subnet AdminRouter-1 AdminNet1-v4-Subnet-1
openstack router add subnet AdminRouter-2 AdminNet2-v4-Subnet-1

neutron router-gateway-set AdminRouter-1 ExtNetFlat
neutron router-gateway-set AdminRouter-2 ExtNetFlat
