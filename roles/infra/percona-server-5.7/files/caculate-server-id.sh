#!/bin/bash

# Use the ip address configured on the first interface card 'eth0' or 'em1' to
# calculate out an server-id for MySQL instance.

# Concatenate the third octet and fourth octet of the ip address together,
# and remove the leading zeroes.

# Use $RANDOM (RANDOM is a system variable) as the server-id if:
# - 'eth0' or 'em1' is not found
# - 'eth0' or 'em1' is found, but the calculated result is not greater than 0.

INTERFACE=''

if `ip link show eth0 >/dev/null 2>&1`; then
  INTERFACE=eth0
elif `ip link show em1 >/dev/null 2>&1`; then
  INTERFACE=em1
else
  INTERFACE='unknown'
fi

if [[ $INTERFACE != 'unknown' ]]; then
  _MYSQL_SERVER_ID=$(ip address show $INTERFACE | grep 'inet ' | head -n1 | \
                      awk '{print $2}' | awk -F'[/.]' '{print $3$4}')
  MYSQL_SERVER_ID=${_MYSQL_SERVER_ID##0}

  if [[ $MYSQL_SERVER_ID -le 0  ]]; then
    MYSQL_SERVER_ID=$RANDOM
  fi
else
  MYSQL_SERVER_ID=$RANDOM
fi

echo $MYSQL_SERVER_ID


