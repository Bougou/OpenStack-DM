# Quick Start

## Prerequisite

### Machines

You need ***Three*** kinds of machines:

1. A deploy machine. 

> This is where you put the source code of this project. Your Mac or a linux machine are both OK.

2. A cluster proxy machine.

> 1. The deploy machine will connect to all target nodes (OpenStack Controller nodes, OpenStack Compute nodes, Ceph Storage ndoes ...) to apply ansible playbooks, but there may be network connection problems for the deploy machine to reach ***ALL those target nodes*** directly. 
> 2. So you MUST choose a proxy machine to play the intermediate role between the deploy machines and all target nodes.
> 3. A cluster proxy machine is a ***MUST*** option even though the network connection problem does not exist.
> 4. The deploy machine use the outer address (`osdm_cluster_proxy_addr_outer`) of the proxy machine to connect to it . And the proxy machine use the innner address (`osdm_cluster_proxy_addr_inner`) to connect to (be connected with) all target nodes.

3. Some target machines.
> Target nodes are the nodes where you run OpenStack cluster and Ceph cluster and other services.
>> In allinone case, one target machine is enough.

## For Deploy machine

```bash
# install ansible
sudo easy_install pip
sudo pip install ansible
sudo pip install netaddr

# or
yum install -y ansible
yum install -y python-netaddr
yum install -y python-ipaddress
```

## Network Plan

see: [Prepare Network and Nic Settings](./Prepare-Network-and-Nic-Settings.md)

## SSH 

There is a `ssh.cfg` file under cluster environment directory which controls how ansible deploy machine connects to the proxy machine and all target machines.

Suppose the `Admin Network` of all target machines is `172.30.15.0/24` and the `osdm_cluster_proxy_addr_outer` is `10.5.252.80`, then `ssh.cfg` will look like this.

```bash
Host 172.30.15.*
  User root
  ProxyCommand ssh -W %h:%p root@10.5.252.80 2>/dev/null
  StrictHostKeyChecking no
  #IdentityFile ~/.ssh/private_key.pem

Host 10.5.252.80
  #StrictHostKeyChecking no
  #User root
  #IdentityFile ~/.ssh/private_key.pem
  #IdentityFile ~/.ssh/id_rsa
  ControlMaster auto
  ControlPath ./.ssh/ansible-%r@%h:%p
  ControlPersist 5m
```

> Note the `ControlPath`, `.ssh` directory is important, make sure this director exists.

## For Allinone

A physical server or a virtual machine with:

- ***One Nic*** (All traffic go through this single nic)
- ***An Extra Disk*** (like: vdb, at least 40G)


## Prepare a new cluster environment

```bash
$ cd osdm/clusters
$ cp -r examples cluster1

$ cd cluster1
# make sure '.ssh' directory exist under this directory
$ mkdir .ssh
```

> All commands execute under the cluster environment directory

## Modify the inventory

> Note: We directly use ***IP Address*** in ansible inventory file, ***DO NOT put hostname*** in it.

```bash
$ vim allinone
# Set the IP address of the target node.

# suppose the ip address of the target node is 172.30.15.98
:%s/127.0.0.1/172.30.15.98/g
```

## Set the cluster proxy node information

```bash
# Set the IP address of the cluster proxy
$ vim group_vars/all/base_settings.yml
osdm_cluster_proxy_addr_outer: 10.5.252.80
osdm_cluster_proxy_addr_inner: 172.30.15.80
```


## Set OpenStack Access VIP Address

```bash
$ vim group_vars/all/osdm_access_vip.yml
osdm_os_access_ext_vip: "10.5.252.198"
osdm_os_access_mgmt_vip: "172.30.17.198"
osdm_os_access_console_ip: "10.5.252.198"
```

## Set Radosgw Access VIP Address

```bash
$ vim group_vars/all/ceph_settings.yml
osdm_radosgw_access_ext_vip: "10.5.252.198"
osdm_radosgw_access_mgmt_vip: "172.30.17.198"
osdm_radosgw_access_domain: "s3.test.com"
```

## Set Ceph OSD disks

```bash
$ vim group_vars/all/ceph_settings.yml
osdm_ceph_osd_disks:
  - 172.30.15.98:vdb
```

## Test connection of the nodes

```bash
$ ansible-playbook -i allinone ../../playbooks/helper/check-conn.yml 
```

## Prepare the node

> Configure networks/iptables/...

```bash
$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-prepare.yaml -e _hosts=all
```

## Install Ceph Packages

```bash
$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-ceph-pkg.yml
```

## Deploy the Ceph Monitors

```bash
$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-ceph-mon-once.yml
```

## Deply the Ceph OSDs

```bash
$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-ceph-osd.yml
```

## Deploy the Ceph Radosgw

```bash
$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-ceph-radosgw.yml
```

## Deploy the MySQL Server

```bash
$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-os-mysql.yml
```

## Deploy the Rabbitmq Server

```bash
$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-os-rabbitmq.yml
```

## Deploy OpenStack Controller Nodes

```bash
$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-os-controller.yml
```

## Deploy OpenStack Network Nodes

```bash
$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-os-network.yml 
```

## Deploy OpenStack Compute Nodes

> Use `-e _hosts=<node_ip-or-group_name>` to specify target nodes.

```bash
$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-os-compute.yml -e _hosts=172.30.15.98
```

## Deploy Keepalived

```bash
$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-keepalived.yml
```

## Test OpenStack Cluster

> upload image/create networks/create  vms/...

```bash
$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-os-final.yml
```

## Deploy Monitor

```bash
$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-mon-collectd-influxdb.yml -e _hosts=172.30.15.98

$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-mon-collectd-server.yml -e _hosts=172.30.15.98

$ ansible-playbook -i allinone ../../playbooks/deploy/deploy-mon-collectd-client.yml -e _hosts=172.30.15.98
```

