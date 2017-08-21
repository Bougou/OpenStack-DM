#!/bin/bash


export cirros_image_id=$(openstack image list | grep cirros | head -n1 | awk '{print $2}')

function create_vm() {
    _net_id=$1
    _vm_name=$2
    _image_id=$3
    _flavor_name=$4
    openstack server create --image ${_image_id} --flavor ${_flavor_name} --security-group default --key-name mytestkey --nic net-id=${_net_id} ${_vm_name}
}

# network uuid
pro_net_flat_id=$(openstack network show ProNetFlat --column id --format value)

create_vm $pro_net_flat_id vm-pro-flat-1 $cirros_image_id test.nano; sleep 3
create_vm $pro_net_flat_id vm-pro-flat-2 $cirros_image_id test.nano; sleep 3

# Environment Variables:
# pro_net_vlan1
# pro_net_vlan2

# netowrk uuid
# pro_net_vlan1 holds VLAN tag number
pro_net_vlan1_id=$(openstack network show "ProNetVLAN$pro_net_vlan1" --column id --format value)

create_vm $pro_net_vlan1_id vm-pro-vlan1-1 $cirros_image_id test.nano; sleep 3
create_vm $pro_net_vlan1_id vm-pro-vlan1-2 $cirros_image_id test.nano; sleep 3

pro_net_vlan2_id=$(openstack network show "ProNetVLAN$pro_net_vlan2" --column id --format value)

create_vm $pro_net_vlan2_id vm-pro-vlan2-1 $cirros_image_id test.nano; sleep 3
create_vm $pro_net_vlan2_id vm-pro-vlan2-2 $cirros_image_id test.nano; sleep 3
