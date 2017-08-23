# Online or Offline Install Mode

The most annoyed problem is the network connection during the `yum install` process. So the `osdm` project provides native support for `offline` install mode.

Before you can use `offline` mode, you should prepare ***all the packages (rpm files)*** in advance before going on.

## `playbooks/download-packages.yml`

The playbook `download-packages.yml` can be used to download all packages needed by the `osdm` project.


