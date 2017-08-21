#!/bin/bash

function add_vip() {
    _if=$1
    _ip=$2
    ip addr add ${_ip}/32 dev $_if
    arping -I $_if -c 3 -U $_ip
}
export -f add_vip  
