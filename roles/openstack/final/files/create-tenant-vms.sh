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
admin_net1_id=$(openstack network show AdminNet1 --column id --format value)
create_vm $admin_net1_id vm-cirros-admin-net1-1 $cirros_image_id test.nano; sleep 3
create_vm $admin_net1_id vm-cirros-admin-net1-2 $cirros_image_id test.nano; sleep 3

admin_net2_id=$(openstack network show AdminNet2 --column id --format value)
create_vm $admin_net2_id vm-cirros-admin-net2-1 $cirros_image_id test.nano; sleep 3
create_vm $admin_net2_id vm-cirros-admin-net2-2 $cirros_image_id test.nano; sleep 3


# floating ip

# ip address.
floating_ip1=$(openstack floating ip create ExtNetFlat --column floating_ip_address --format value)
openstack server add floating ip vm-cirros-admin-net1-1 $floating_ip1
# openstack server remove floating ip vm-admin-net1-1 $floating_ip1
# openstack floating ip list

# Legacy.
# neutron floatingip-create ExtNetFlat
# neutron floatingip-associate <floatingip_id> <port_id>
# neutron floatingip-disassociate <floatingip_id>
# neutron floatingip-list
