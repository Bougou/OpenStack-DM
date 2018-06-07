#!/bin/bash

source /tmp/inf_utils.sh

# clear interfaces connection

# Exteranl Network
if [[ "$osdm_node_nics_ext_if" != "$osdm_node_nics_admin_if" ]]; then
  clear_nics $osdm_node_nics_ext_if
  clear_ovsbr_and_nics "$osdm_node_nics_ext_if"
fi
clear_vlan_dev $osdm_os_ext_vlan
ext_nic_ovs_brname=$(make_ovs_brname "$osdm_node_nics_ext_if")
clear_ovsbr_and_patch $ext_nic_ovs_brname "br-ex"


# MANAGEMENT Network
if [[ "$osdm_node_nics_mgmt_if" != "$osdm_node_nics_admin_if" ]]; then
  clear_nics $osdm_node_nics_mgmt_if
  clear_ovsbr_and_nics "$osdm_node_nics_mgmt_if"
fi
clear_vlan_dev $osdm_os_mgmt_vlan
mgmt_nic_ovs_brname=$(make_ovs_brname "$osdm_node_nics_mgmt_if")
clear_ovsbr_and_patch $mgmt_nic_ovs_brname "br-mgmt"


# DATA Network (nova-network)
if [[ "$osdm_node_nics_data_if" != "$osdm_node_nics_admin_if" ]]; then
  clear_nics $osdm_node_nics_data_if
fi


# TENANT Network (neutron)
if [[ "$osdm_node_nics_ten_if" != "$osdm_node_nics_admin_if" ]]; then
  clear_nics $osdm_node_nics_ten_if
  clear_ovsbr_and_nics "$osdm_node_nics_ten_if"
fi
clear_vlan_dev $osdm_os_ten_vlan
ten_nic_ovs_brname=$(make_ovs_brname "$osdm_node_nics_ten_if")
clear_ovsbr_and_patch $ten_nic_ovs_brname "br-ten"


# PROVIDER Network (neutron)
if [[ "$osdm_node_nics_pro_if" != "$osdm_node_nics_admin_if" ]]; then
  clear_nics $osdm_node_nics_pro_if
  clear_ovsbr_and_nics "$osdm_node_nics_pro_if"
fi
pro_nic_ovs_brname=$(make_ovs_brname "$osdm_node_nics_pro_if")
clear_ovsbr_and_patch $pro_nic_ovs_brname "br-pro"


# STOR Network
if [[ "$osdm_node_nics_stor_if" != "$osdm_node_nics_admin_if" ]]; then
  clear_nics $osdm_node_nics_stor_if
  clear_ovsbr_and_nics "$osdm_node_nics_stor_if"
fi
clear_vlan_dev $osdm_os_stor_vlan
stor_nic_ovs_brname=$(make_ovs_brname "$osdm_node_nics_stor_if")
clear_ovsbr_and_patch $stor_nic_ovs_brname "br-stor"


# If osdm_node_nics_admin_if is shared with other function nics, the clear
# process did not remove the OVSPatchPort on the ovsbridge `ovsbr-ethX`
# shared by admin network and other function networks.
# So, restart network service to remove the patch port on the ovsbridge.
if [[ "$osdm_node_nics_admin_dedicated" == 'false' ]]; then
  systemc restart network
fi

echo 'Interfaces clear finished'
