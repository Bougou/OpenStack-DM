# Purpose

Each nova cell should has its own `osdm_cell_access_mgmt_vip`.

Nova cell does not need to set `osdm_cell_access_ext_vip` for external access.

The `osdm_cell_access_mgmt_vip` should be set on ansible per-group group_vars file. There is a default
