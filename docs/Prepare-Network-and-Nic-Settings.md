# Prepare Network and Nic Settings

- group_vars/all/nic_settings.yml
- group_vars/all/ipmi_settings.yml

## Network Functionalities

> We divide all networks to the following categories

Network Purpose | Abbr | Default Vlan | Desc
--- | --- | --- | ---
Admin | admin | 15 |
IPMI | ipmi | 16 |
Management | mgmt| 17 |
External | ext | 886 |
Data | data | 19 | only for nova-network, Deprecated
Tenant | ten | 20 | only for neutron Tenant
Provider | pro | 21 | only for neutron Provider
Storage | stor | 22 | only for ceph cluster network

## Prepare Admin Network

The Admin Network is used for ansible deploy machine (proxy machine) to connect to target nodes to execute ansible tasks. The network configuration of it is neither managed nor changed by our deploy procedure. So you need to set the ip address infomation of the Admin network in advance on each node.

In most cases, you should use one dedicated interface of the node for the Admin network as following:

```yaml
osdm_node_nics_admin_if: "eth0"
osdm_node_nics_admin_dedicated: true
osdm_os_admin_if: "eth0"
```

But if your node only has one nic and you still want to use this project to test or deploy an openstack cluster. You can take the following workaround.

You should create a sperate linux vlan interface like `vlan15@eth0`. Use this vlan interface as the admin network and set IP address on this vlan interface.

```yaml
osdm_node_nics_admin_if: "eth0"
osdm_node_nics_admin_dedicated: false
osdm_os_admin_if: "vlan15"
```

## The IPMI Network

The IPMI network will share the first network interface in Physical machines. Don't care of it if you use virtual machines for test.

```yaml
osdm_ipmi_lan_vlan: 16
osdm_ipmi_lan_net: 172.30.16.0/24
osdm_ipmi_lan_gw: 172.30.16.254
```

## External/Management/Tenant/Provider/Storage

### Network Configuration

The External/Management/Storage/Data/Tenant/Provider networks are networks used by the OpenStack cluster. Each of them should have a separate subnet configuration like:

```yaml
osdm_os_mgmt_name: "management"
osdm_os_mgmt_net: 172.30.17.0/24
osdm_os_mgmt_gw: 172.30.17.254
osdm_os_mgmt_metric: 2
osdm_os_mgmt_vlan: 17
```

The ***External network*** is used to connect the OpenStack cluster with the outside, so you should specify the External network setting ***according to you own environment***.

The ***Management/Storage/Data/Tenant/Provider*** networks is used only inside the OpenStack cluster, so you can use the preset configuration in the `nic_settings.yml` file.

#### gw/vlan/metric

Detail explanations of gw/vlan/metric can be seen from the comments in `nic_settings.yml` file.

But for simplicity, you shoud set the switch ports connected with those server nodes to `trunk` mode and allow all vlans pass through. In VMware workstation test environment, you don't have to worry about the underneath virtual switch configuration.

### Which Networks should a Node configure?

Not all networks will be needed on all target nodes, so you can use `osdm_configure_<name>_if: <true/false>`  like variables on a per-node ansible ***host_vars*** file or on a ***per-group ansible group_vars*** to control wether to configure the specific networks for the target nodes.

For simplity, all those `osdm_configure_<name>_if` is set to true.

Examples of `ansible group_vars file` or `ansbile host_vars file`:

```yaml
# osdm_node_nics_admin_if: "eth0"

# osdm_configure_ext_if: true
# osdm_node_nics_ext_if: "eth0"
# osdm_node_nics_ext_dedicated: false

# osdm_configure_mgmt_if: true
# osdm_node_nics_mgmt_if: "eth0"
# osdm_node_nics_mgmt_dedicated: false

# osdm_configure_data_if: false
# osdm_node_nics_data_if: "eth0"
# osdm_node_nics_data_dedicated: false

# osdm_configure_stor_if: true
# osdm_node_nics_stor_if: "eth0"
# osdm_node_nics_stor_dedicated: false

# osdm_configure_ten_if: false
# osdm_node_nics_ten_if: "eth0"
# osdm_node_nics_ten_dedicated: false

# osdm_configure_pro_if: false
# osdm_node_nics_pro_if: "eth0"
# osdm_node_nics_pro_dedicated: false
```

### Allocate nics of the node to different networks

All those networks can share a single nic interface, or can share a bonded two interfaces, or can use their dedicated interfaces if you have enough nic interfaces. If a network does not use an interface or a boned two interfaces exclusively, you should set `osdm_node_nics_<name>_dedicated` to false.

You can set them like this:

```yaml
# The management network share eth0 interface with other networks.
osdm_node_nics_mgmt_if: "eth0"
osdm_node_nics_mgmt_dedicated: false

# The storage network use eth1 and eth2 interfaces exclusively.
osdm_node_nics_stor_if: "eth1 eth2"
osdm_node_nics_stor_dedicated: true
```
