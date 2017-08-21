#!/bin/bash

# Remove the old secret uuid if exists
old_secret_uuid=$(virsh secret-list | grep "client.cinder secret" | awk '{print $1}')
[[ "X$old_secret_uuid" != "X" ]] && virsh secret-undefine $old_secret_uuid

# define secret
# secret.xml was fetched from the ansible role fetch_ceph_key
virsh secret-define --file /etc/ceph/secret.xml
virsh secret-set-value --secret $osdm_ceph_libvirt_uuid_secret --base64 $(cat /etc/ceph/ceph.client.cinder.key)
