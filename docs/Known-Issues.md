# Known Issues

GlusterFS defaults to use `option base-port 49152` as the port for `glusterfsd`.
Libvirt live migration also defaults to use ports started from 49152.
When libvirtd and glusterd run on the same node, this might cause problems.

- https://www.gluster.org/pipermail/gluster-users/2014-January/015820.html
- https://bugzilla.redhat.com/show_bug.cgi?id=1023653
