`osdm` is an OpenStack Deploy Manager using Ansible specifically for CentOS 7.

> Frankly speaking, the deployment future of openstack is kolla and docker container. But for people who are not so familar with docker container, the traditional operating system builtin package management tool (yum or apt) seems more friendly.

## Notable Features

- Enough variables to tweak to suit your own deploy case.
- Support nova cell configuration.
- Support Allinone or 2 controllers or 3+ controllers deployment use case.
- Use collectd+influxdb+grafana for monitoring.
- Only ***one nic*** of the node is enough for testing purpose.
- Deploy/Manage different clusters (environment) at the same place.
- Use ssh proxy node to connect to remote cluster environment.
- Can choose yum ***online*** install or local rpm ***offline*** install.

## Other Links

- [Quick Start](docs/Quick-Start.md)
- [Prepare Network and Nic Settings](docs/Prepare-Network-and-Nic-Settings.md)
- [Database Strategy](docs/Database-Strategy.md)
- [Nova Cell](docs/Nova-Cell.md)
- [Known Issues](docs/Known-Issues.md)
