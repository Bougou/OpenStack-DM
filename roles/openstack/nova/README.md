# Purpose

This role is used to install nova service on the controller node and compute node.

From OpenStack ocata release, nova Cell is a must option to configure.

There are three variables you can use to indicate which to install when using this role, both default to false.

```yaml
# deploy api_cell (cell0) and the first nova_cell (cell1)
nova_deploy_api_cell: false

# deploy extra nova_cell, like (cell2)
nova_deploy_nova_cell: false

# deploy nova_compute node.
nova_deploy_nova_compute: false
```

In `deploy-os-controller` playbook, we use set `nova_deploy_api_cell` to true.
