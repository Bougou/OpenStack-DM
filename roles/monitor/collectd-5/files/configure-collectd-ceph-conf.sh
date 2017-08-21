#!/bin/bash

exec >/dev/null

## collectd ceph plugin.
cat <<EOF > /etc/collectd.d/ceph.conf
LoadPlugin ceph
<Plugin ceph>
  LongRunAvgLatency false
  ConvertSpecialMetricTypes true
EOF

for i in `ls /var/run/ceph/*.asok`; do
  filename=${i##*/};
  fileprefix=${filename%%.asok};
cat <<EOF >> /etc/collectd.d/ceph.conf
  <Daemon "$fileprefix">
    SocketPath "$i"
  </Daemon>
EOF
done

cat <<EOF >> /etc/collectd.d/ceph.conf
</Plugin>
EOF
