# Purpose

This role is used to caculate the ip address of the management, external, storage, tenant, provider network for the target node.

At the very first, a node only has an admin network ip address configured.

We set the other networks subnet information under group_vars. So we use a python script to caculate out the other ip addresses.

The caculated ip addresses will be output through ansible `set_fact` task. There are five new facts for each network like following.

```yaml
osdm_os_ext_if_addr: 10.5.252.98/24
osdm_os_ext_if_ip: 10.5.252.98
osdm_os_ext_if_netmask: 255.255.255.0
osdm_os_ext_if_prefix: 24
osdm_os_ext_if_ipv4: {
    'address': 10.5.252.98,
    'prefix': 24,
    'netmask': 255.255.255.0
}
```

The output facts will be used mainly in two places.

1. Used by `set_ipaddr` role  to configure ip address on the specific network interface.
2. Used in `nova.conf` etc configuration file to fill in address.
