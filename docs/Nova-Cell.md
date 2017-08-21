# Nova Cell

### Cell 1

1. By default, the controller nodes are also be used as cell-controller nodes of cell1.
2. All the nodes (include cell-controller and cell-compute) of one cell MUST NOT intersect with other cells.
3. The cell name are set as vars for each cell group (like os-cell-all_cell1), and so be used as variables by all hosts of this cell group.


### Adding a new Cell

```bash
# os-controller: nova-api/nova-scheduler/keystone/glance/neutron-api/*-api/, nova-conductor for (db: nova_api, nova_cell0)
# os-network: neutron-l3-agent
# os-compute: all nova-compute(s) from all nova cells
# os-cell-controller: nova-conductor for (db: nova_cell*)

## When add a new Cell, name is 'cell1':
# - 1. add a new group [os-cell-controller_cell1]
# - 2. add a new group [os-cell-compute_cell1]
# - 3. add a new group [os-cell-all_cell1] includes [os-cell-controller_cell1]+[os-cell-compute_cell1]
# - 4. add 'os-cell-controller_cell1' as child of group [os-cell-controller]
# - 5. add 'os-cell-compute_cell1' as child of group [os-compute]
```

