#!/bin/bash

# remove-osd.sh <osd.n>

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <osd.num>"
  echo "Example: $0 osd.3"
  exit 1
fi

OSD=$1


# Before make OSD out, better to reweight it to limit the impact.

# Step1. Mark the OSD out of the cluster.
ceph osd out $OSD

## Stop the OSD daemon

# Remove the OSD from the cluster map.
ceph osd crush remove $OSD

# Remove the OSD authentication key.
ceph auth del $OSD

# Remove the OSD from the OSD map.
ceph osd rm $OSD
