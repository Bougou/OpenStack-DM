## Purpose

This ansible role is used to deploy/add Ceph OSDs to the Ceph cluster.

This role should be applied to the **Ceph Admin Deploy** Node (where you use ceph-deploy to manage you ceph cluster).

In most case, we usually use the first of the three Ceph Monitor nodes to act as ***Ceph Admin Deploy** node.

This role is usually used when bootstraping the ceph cluster for the first time. I suggest not to use this role to adding new osds for expanding ceph cluster when the cluster is on service. You should manaully add/remove osds to take more control on ***ceph rebalance process***.
