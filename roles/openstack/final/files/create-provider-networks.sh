#!/bin/bash

# osdm_ft_pro_flat='1'
# osdm_ft_pro_flat_range
# osdm_ft_pro_flat_gateway
# osdm_ft_pro_flat_pool_start
# osdm_ft_pro_flat_pool_end
# osdm_ft_pro_vlan1='51'
# osdm_ft_pro_vlan1_range
# osdm_ft_pro_vlan1_gateway
# osdm_ft_pro_vlan1_pool_start
# osdm_ft_pro_vlan1_pool_end
# osdm_ft_pro_vlan2='51'
# osdm_ft_pro_vlan2_range
# osdm_ft_pro_vlan2_gateway
# osdm_ft_pro_vlan2_pool_start
# osdm_ft_pro_vlan2_pool_end


# ProviderNetwork - Flat
if [[ "X$osdm_ft_pro_flat" == 'X1' ]]; then
openstack network create \
    --share \
    --provider-network-type flat \
    --provider-physical-network physnet-pro \
    ProNetFlat

openstack subnet create \
    --network ProNetFlat \
    --ip-version 4 \
    --subnet-range $osdm_ft_pro_flat_range \
    --allocation-pool start=$osdm_ft_pro_flat_pool_start,end=$osdm_ft_pro_flat_pool_end \
    --gateway $osdm_ft_pro_flat_gateway \
    ProNetFlat-v4-Subnet-1
fi


# ProviderNetwork - VLAN - 1
if [[ "X$osdm_ft_pro_vlan1" != 'X' ]]; then
openstack network create \
    --share \
    --provider-network-type vlan \
    --provider-physical-network physnet-pro \
    --provider-segment $osdm_ft_pro_vlan1 \
    ProNetVLAN$osdm_ft_pro_vlan1

openstack subnet create \
    --network ProNetVLAN$osdm_ft_pro_vlan1 \
    --ip-version 4 \
    --subnet-range $osdm_ft_pro_vlan1_range \
    --allocation-pool start=$osdm_ft_pro_vlan1_pool_start,end=$osdm_ft_pro_vlan1_pool_end \
    --gateway $osdm_ft_pro_vlan1_gateway \
    ProNetVLAN${osdm_ft_pro_vlan1}-v4-Subnet-1
fi


# ProviderNetwork - VLAN - 2
if [[ "X$osdm_ft_pro_vlan2" != 'X' ]]; then
openstack network create \
    --share \
    --provider-network-type vlan \
    --provider-physical-network physnet-pro \
    --provider-segment $osdm_ft_pro_vlan2 \
    ProNetVLAN$osdm_ft_pro_vlan2

openstack subnet create \
    --network ProNetVLAN$osdm_ft_pro_vlan2 \
    --ip-version 4 \
    --subnet-range $osdm_ft_pro_vlan2_range\
    --allocation-pool start=$osdm_ft_pro_vlan2_pool_start,end=$osdm_ft_pro_vlan2_pool_end \
    --gateway $osdm_ft_pro_vlan2_gateway \
    ProNetVLAN${osdm_ft_pro_vlan2}-v4-Subnet-1
fi
