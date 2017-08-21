# Inventory Groups

- os-all
    - os-controller [*]
    - os-network [*]
    - os-cell-controller
        - os-cell-controller_cell1 [*] (equals to os-controller)
        - os-cell-controller_cell2 (if exist)
    - os-compute
        - os-cell-compute_cell1 [*]
        - os-cell-compute_cell2 (if exist)
- ceph-all
    - ceph-mon [*]
    - ceph-radosgw [*]
    - ceph-osd [*]
- monitor
- collectd-server
- influxdb
- grafana
