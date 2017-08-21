# Database Strategy

There are two ansible roles which can be used to deploy mysql `infra/percona-server-5.6` and `infra/pxc-5.6`.

According to the number of nodes under `[os-controller]` group, the `deploy-os-mysql.yml` playbook use different methods to install mysql.

If there is only One node, simple use `infra/percona-server-5.6` role to install a single node mysql server.

If there are two nodes, use `infra/percona-server-5.6` role to install a mysql master slave cluster.

If there are three or more nodes, use `infra/pxc-5.6` role to install a pxc multi master cluster.
