#!/usr/bin/bash

## see: https://bugzilla.redhat.com/show_bug.cgi?id=1158115
## This script should be put in /usr/libexec/keepalived/
## make sure selinux context is correct.
## restorecon -R /usr/libexec/keepalived/

## $1 = A string indicating whether it's a "GROUP" or an "INSTANCE"
## $2 = The name of said group or instance
## $3 = The state it's transitioning to ("MASTER", "BACKUP" or "FAULT")
## $4 = The priority value

TYPE=$1
NAME=$2
STATE=$3

case $STATE in
  "MASTER")
    # sh -x keepalived-status-change-to-master.sh
    exit 0
    ;;
  "BACKUP")
    # sh -x keepalived-status-change-to-backup.sh
    # systemctl stop haproxy
    exit 0
    ;;
  "FAULT")
    # systemctl stop haproxy
    exit 0
    ;;
  *)
    echo "unknown state"
    exit 1
    ;;
esac
