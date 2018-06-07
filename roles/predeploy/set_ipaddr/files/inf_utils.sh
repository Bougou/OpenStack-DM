#!/bin/bash

function exists_con_name() {
    con_name=$1
    if `nmcli con | grep -sq "^$con_name "`; then
        return 0
    else
        return 1
    fi
}
export -f exists_con_name


# Remove connection if exists
# eg: remove_con_name <con-name>
function remove_con_name() {
    con_name=$1
    if `nmcli con | grep -sq "^$con_name "`; then
        nmcli con del $con_name
    fi
}
export -f remove_con_name


function remove_dev_name() {
    dev_name=$1
    if `nmcli dev | grep -sq "^$dev_name "`; then
        nmcli dev del $dev_name
    fi
}
export -f remove_dev_name


# Return the team name string based on all its slave interfaces.
# eg: 'make_teamname bond eth1 eth2' return 'bond-eth1-eth2' as the team name.
function make_teamname() {
    _type=$1
    _nics=(${@#$1})
    _teamname=$_type
    for _nic in ${_nics[@]}; do
        _nic=$(echo $_nic | tr -d " '")
        _teamname="${_teamname}-${_nic}"
    done
    echo $_teamname
}
export -f make_teamname


# Using nmcli to create a Team interfaces based on all its slave interfaces.
# eg: make_team <type> <mode> <nic1> <nic2>
function make_team() {
    _type=$1
    _mode=$2

    _nics_tmp=${@#$_type} # strip <type>
    _nics=${_nics_tmp#$_mode} # strip <mode>

    _teamname=$(make_teamname $_type $_nics)

    exists_con_name $_teamname && return

    nmcli con add type $_type con-name $_teamname ifname $_teamname
    nmcli con mod $_teamname ipv4.method disabled ipv6.method ignore

    [[ $_type == 'team' ]] && nmcli con mod $_teamname team.config "{\"runner\": {\"name\": \"$_mode\"}}"
    [[ $_type == 'bond' ]] && nmcli con mod $_teamname bond.options mode=$_mode

    # re-up the connection after modify it.
    ip link set $_teamname up
    nmcli con up $_teamname

    for _nic in $_nics; do
        nmcli dev disconnect $_nic
        ip link set $_nic up
        nmcli con add type "${_type}-slave" con-name ${_type}-$_nic ifname $_nic master $_teamname
    done

    sleep 1; nmcli con up $_teamname
    for _nic in $_nics; do
        ip link set $_nic up
        nmcli con up ${_type}-$_nic
    done
}
export -f make_team


# make_ethernet eth1
function make_ethernet() {
    _nic=$1

    exists_con_name $_nic && return

    nmcli dev disconnect $_nic
    ip link set $_nic up
    nmcli con add type ethernet con-name $_nic ifname $_nic
    nmcli con mod $_nic ipv4.method disabled ipv6.method ignore
    # re-up the connection after modify it.
    nmcli con up $_nic
}
export -f make_ethernet


# make_vlan <id> <dev>
function make_vlan() {
    _id=$1
    _dev=$2

    exists_con_name vlan$_id && return

    ip link set $_dev up
    nmcli con add type vlan con-name vlan$_id ifname vlan$_id dev $_dev id $_id
    nmcli con mod vlan$_id ipv4.method disabled ipv6.method ignore
    # re-up the connection after modify it.
    nmcli con up vlan$_id
}
export -f make_vlan


function clear_nics() {
    _node_nics=($@)
    _nics_num=${#_node_nics[@]}

    # if nics num is greater than 1, it means there might exist a team connection
    # so try to remove the team connection.
    # first remove team-slave connection, then remove team-master connection
    if [[ $_nics_num -gt 1 ]]; then
        for _nic in ${_node_nics[@]}; do
            remove_con_name "$_nic"
            remove_con_name "team-$_nic"
            remove_con_name "bond-$_nic"
            # for team slave connection, there not exist a corresponding virtual device.
            # So no need to remove_dev_name
        done

        _teamname=$(make_teamname team ${_node_nics[@]})
        remove_con_name $_teamname
        remove_dev_name $_teamname

        _teamname=$(make_teamname bond ${_node_nics[@]})
        remove_con_name $_teamname
        remove_dev_name $_teamname
    else
        remove_con_name "$_node_nics"
        # if nics num is equal to 1, it means this is a single hardware device.
        # hardware device can not be deleted.
        # So there is no need to remove_dev_name
    fi
}
export -f clear_nics


function clear_vlan_dev() {
    _id=$1
    remove_con_name "vlan$_id"
    remove_dev_name "vlan$_id"
}
export -f clear_vlan_dev


function prepare_os_if() {
    set -x
    echo "Hello: $osdm_network_mode"
    echo "Hello: $osdm_team_mode"
    echo "Hello: $osdm_team_type"

    if [[ "$osdm_network_mode" == 'neutron' ]]; then
        prepare_os_if_neutron "$@"
    fi

    if [[ "$osdm_network_mode" == 'nova-network' ]]; then
        prepare_os_if_nn "$@"
    fi
}
export prepare_os_if


function prepare_os_if_nn() {
    set -x
    _node_nics_x_if="$1"
    _node_nics_x_dedicated=$2
    _os_x_vlan=$3
    _os_x_if_addr=$4
    _os_x_if_gw=$5
    _os_x_if_metric=$6

    _node_nics_x_if_list=($_node_nics_x_if)
    _node_nics_x_if_num=${#_node_nics_x_if_list[@]}

    ## osdm_team_type and osdm_team_mode are all environment variables.
    if [[ $_node_nics_x_if_num -gt 1 ]]; then
        make_team $osdm_team_type $osdm_team_mode $_node_nics_x_if
        _node_nics_x_if=$(make_teamname $osdm_team_type $_node_nics_x_if)
    else
        make_ethernet $_node_nics_x_if
    fi
    # From now on, _node_nics_x_if is either an ethernet interface 'ethX'
    # or a team interface 'team-ethX-ethX'

    #ip link set $_node_nics_x_if up

    if [[ $# -eq 1 ]]; then return; fi

    if [[ $_node_nics_x_dedicated == 'True' ]]; then
        _os_x_if=$_node_nics_x_if
    else
        make_vlan $_os_x_vlan $_node_nics_x_if
        _os_x_if=vlan$_os_x_vlan
    fi
    # From now on, _os_x_if is either an ethernet/team interface for dedicated
    # or a vlan interface 'vlanID' for shared.

    # congiure ip address
    nmcli con mod $_os_x_if ipv4.method manual ipv4.addresses $_os_x_if_addr
    if [[ $_os_x_if_gw != '0.0.0.0' ]]; then
        nmcli con mod $_os_x_if ipv4.gateway $_os_x_if_gw
    fi
    if [[ $_os_x_if_metric != '-1' ]]; then
        nmcli con mod $_os_x_if ipv4.route-metric $_os_x_if_metric
    fi
    # re-up the connection after modify it.
    nmcli con up $_os_x_if

    # sleep 5
    # ip link set dev $_os_x_if up

#    # for lacp team interface bug
#    # _node_nics_x_if_num=${#_node_nics_x_if_list[@]}
#    if [[ $_node_nics_x_if_num -gt 1 ]]; then
#        # _node_nics_x_if already becomes virtual team interface
#        nmcli con up $_node_nics_x_if
#        for _nic in ${_node_nics_x_if_list[@]}; do
#            nmcli con up team-$_nic
#        done
#    fi
}
export -f prepare_os_if_nn


##
## For neutron deployment
##


# For ovs bridge with uplink to Physical nics, name should be like 'ovsbr-eth0' or 'ovsbr-eth0-eth1'
# For ovs bridge without uplink to Physical nics, name should be 'br-ex, br-mgmt' or 'ovsbr-N'.
# The `minus` sign after 'ovsbr' or 'br' prefix is the separator used to fetch out the left part of the bridge name.
# Like `eth0-eth1` in 'ovsbr-eth0-eth' or `ex` in 'br-ex'.
# These strings will be used when creating ovs patchport.

# For ovs NIC port, ifcfg-* name should be like 'ovsport-eth0'
# For ovs bondport, name should be like 'ovsbond-eth0-eth1'
# For ovs patchport, name should be like:
#   - 'eth0-eth1-patch-ex' (patchport on ovsbr-eth0-eth1 to br-ex),
#   - 'ex-patch-eth0-eth1' (patchport on br-ex to ovsbr-eth0-eth1).


# eg: clear_ovsbr <ovsbr>
# Deletes bridge and all of its ports.
function clear_ovsbr() {
    ovs-vsctl --if-exists del-br $1
}

# eg: rm_ifcfg_file <file>
function rm_ifcfg_file() {
    [[ -f "/etc/sysconfig/network-scripts/$1" ]] && rm -rf "/etc/sysconfig/network-scripts/$1" || :
}


# eg: clear_ovsbr_and_patch <ovsbr1> <ovsbr2>
# ovsbr1 is the bridge will NOT Be deleted, but the patch port relate to ovsbr2 ont it will be deleted.
# ovsbr2 is the bridge will be deleted, and the patch port relate to ovsbr1 on it will be deleted.
function clear_ovsbr_and_patch() {
    _br1=$1
    _br2=$2

    _name1=${_br1#*-}
    _name2=${_br2#*-}

    _patch1=${_name1}-patch-${_name2}
    _patch2=${_name2}-patch-${_name1}

    clear_ovsbr ${_br2}
    rm_ifcfg_file ifcfg-${_br2}
    rm_ifcfg_file ifcfg-${_patch1}
    rm_ifcfg_file ifcfg-${_patch2}
}


# eg: clear_ovsbr_and_nics "<nics>"
function clear_ovsbr_and_nics() {
    _nics=($@)
    _nics_num=${#_nics[@]}

    # if nics num is greater than 1, it means there might exist an ovs bridge like 'ovsbr-eth0-eth1' and an ovs bondport like 'ovsbond-eth0-eth1'.
    # so try to remove the ovs bridge and delete the ifcfg-* files.
    if [[ $_nics_num -gt 1 ]]; then
        _ovs_brname=$(make_ovs_brname "$_nics")
        _ovs_bondportname=$(make_ovs_bondportname "$_nics")
        clear_ovsbr $_ovs_brname
        rm_ifcfg_file ifcfg-$_ovs_brname
        rm_ifcfg_file ifcfg-$_ovs_bondportname
    else
    # if nics num is not greater than 1, it means there exists an ovs bridge like 'ovsbr-eth0' and an ovs NIC port like 'ovsport-eth0'.
    # so try to remove the ovs bridge and delete the ifcfg-* files.
        _ovs_brname=$(make_ovs_brname "$_nics")
        clear_ovsbr $_ovs_brname
        rm_ifcfg_file ifcfg-$_ovs_brname
        rm_ifcfg_file ifcfg-ovsport-$_nics
    fi
}


# eg: make_ovs_bondportname "<nic1> <nic2> [...]"
# interfaces are provided as a string.
function make_ovs_bondportname() {
    _nics="$1"
    _ovs_bondportname="ovsbond"
    for _nic in ${_nics[@]}; do
        _nic=$(echo $_nic | tr -d " '")
        _ovs_bondportname="${_ovs_bondportname}-${_nic}"
    done
    echo $_ovs_bondportname
}
export -f make_ovs_bondportname


# eg: make_ovs_brname "<nic1> [<nic2> ...]"
# interfaces are provided as a string.
function make_ovs_brname() {
    _nics="$1"
    _ovs_brname="ovsbr"
    for _nic in ${_nics[@]}; do
        _nic=$(echo $_nic | tr -d " '")
        _ovs_brname="${_ovs_brname}-${_nic}"
    done
    echo $_ovs_brname
}
export -f make_ovs_brname


# The reason to use ifcfg- style to create ovs bridge instead of using `ovs-vsctl` command is:
# Authough bridges created by `ovs-vsctl`persists after system reboot,
# but the ip address infomation still will be lost if it's not written to ifcfg- file.
# So we use ifcfg- file to create the ovs bridge and assign ip address.


# eg: make_ovs_nicport <nic>
# The <nic> is an ethernet interface `ethX` which will be added as a port on ovs bridge named `ovsbr-ethX`
# The `ovsbr-ethX` bridge should be created by calling function `make_ovs_br_from_nicss`
# OVS Port TYPE: OVSPort
function make_ovs_nicport() {
    _nic="$1"    # eth0
    _ovs_brname=$(make_ovs_brname "$_nic") # ovsbr-eth0

cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-ovsport-$_nic
DEVICE=$_nic
DEVICETYPE=ovs
TYPE=OVSPort
OVS_BRIDGE=${_ovs_brname}
ONBOOT=yes
BOOTPROTO=none
EOF
}
export -f make_ovs_nicport


# eg: make_ovs_bondport <mode> "<nic1> <nic2> ..."
function make_ovs_bondport() {
    _mode="$1"
    #_nics=${@#$_mode} # strip out <mode>
    _nics="$2"
    _ovs_bondportname=$(make_ovs_bondportname "$_nics")
    _ovs_brname=$(make_ovs_brname "$_nics")

cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-${_ovs_bondportname}
DEVICE=${_ovs_bondportname}
DEVICETYPE=${_ovs_bondportname}
TYPE=OVSBond
OVS_BRIDGE=${_ovs_brname}
BOND_IFACES="${_nics}"
OVS_OPTIONS="bond_mode=${_mode}"
ONBOOT=yes
BOOTPROTO=none
EOF
}
export -f make_ovs_bondport


# eg: make_ovs_vlanport <ovsbr> <vlanid>
# OVS Port TYPE: OVSIntPort
function make_ovs_vlanport() {
    _ovs_brname="$1"
    _tag="$2"

cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-ovsvlan-$_tag
DEVICE=ovsvlan-$_tag
DEVICETYPE=ovs
TYPE=OVSIntPort
OVS_BRIDGE=${_ovs_brname}
ONBOOT=yes
BOOTPROTO=none
OVS_OPTIONS="tag=$_tag"
OVS_EXTRA=
IPADDR=
PREFIX=
GATEWAY=
METRIC=
EOF
}
export -f make_ovs_vlanport


# eg: make_ovs_trunkport <ovsbr> <portname>
function make_ovs_trunkport() {
    _ovs_brname="$1"
    _portname="$2"

cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-ovstrunk-$_portname
DEVICE=ovstrunk-$_portname
DEVICETYPE=ovs
TYPE=OVSIntPort
OVS_BRIDGE=${_ovs_brname}
ONBOOT=yes
BOOTPROTO=none
OVS_OPTIONS=
OVS_EXTRA=
IPADDR=
PREFIX=
GATEWAY=
METRIC=
EOF
}
export -f make_ovs_trunkport


# eg: make_ovs_br_from_nics <nics> <ip_info>
# the nics provided here are just for name purpose.
# nics can be only one ethernet interface.
# the ethernet port relation to ovs bridge is not created by this.
function make_ovs_br_from_nics() {
    _nics="$1"
    _ip_info="$2"
    # format of ip info a string with at most three fields separated by space:
    # `<ipaddr> <gateway> <metric>`
    # just two fields in the string means <metric> is ignored.
    # just one fields in the string means <gateway> is ignored.
    # format of ipaddr is: `192.168.1.1/24`
    #
    _ip_info_ipaddr=$(echo $_ip_info | awk '{print $1}')
    _ip_info_gateway=$(echo $_ip_info | awk '{print $2}')
    _ip_info_metric=$(echo $_ip_info | awk '{print $3}')

    _ovs_brname=$(make_ovs_brname "$_nics")

# if _ip_info_* is empty, we still leave `IPADDR=,PREFIX=,GATEWAY=,METRIC=` in ifcfg- file.
cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-${_ovs_brname}
NAME=${_ovs_brname}
DEVICE=${_ovs_brname}
DEVICETYPE=ovs
TYPE=OVSBridge
OVS_EXTRA="set bridge \$DEVICE datapath_type=${osdm_ovs_datapath_type}"
ONBOOT=yes
BOOTPROTO=none
NOZEROCONF=yes
IPADDR=${_ip_info_ipaddr%%/*}
PREFIX=${_ip_info_ipaddr##*/}
GATEWAY=${_ip_info_gateway}
METRIC=${_ip_info_metric}
EOF
}
export -f make_ovs_br_from_nics


# eg: make_ovs_br_from_br <ovsbr1> <ovsbr2> <tag> <ip_info>
# make_ovs_br_from_br ovsbr-eth0-eth1 br-ex 17 "192.168.17.11/24 192.168.17.254 -1"
# using ovs patch to connect ovsbr1 and ovsbr2
# ovsbr1 should already exist, ovsbr2 will be created.
#
function make_ovs_br_from_br() {
    _br1="$1"
    _br2="$2"
    _tag="$3"
    _ip_info="$4"
    # format of ip info is: `<ipaddr> <gateway> <metric>`
    # format of ipaddr is: `192.168.1.1/24`
    _ip_info_ipaddr=$(echo $_ip_info | awk '{print $1}')
    _ip_info_gateway=$(echo $_ip_info | awk '{print $2}')
    _ip_info_metric=$(echo $_ip_info | awk '{print $3}')

    [[ X"$_ip_info_ipaddr" == "Xnone" ]] && _ip_info_ipaddr=''
    [[ X"$_ip_info_gateway" == "Xnone" ]] && _ip_info_gateway=''
    [[ X"$_ip_info_metric" == "Xnone" ]] && _ip_info_metric=''


    if [[ $_tag != "none" ]]; then
        # set ovs port to `access mode`
        _ovs_options="tag=${_tag}"
    else
        ## ovs port default to `trunk mode`
        # _ovs_options="trunk=10,11" explicitly specify the allowed vlan
        _ovs_options=""
   fi

    _name1=${_br1#*-}
    _name2=${_br2#*-}

    _patch1=${_name1}-patch-${_name2}
    _patch2=${_name2}-patch-${_name1}

cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-${_br2}
NAME=${_br2}
DEVICE=${_br2}
DEVICETYPE=ovs
TYPE=OVSBridge
OVS_EXTRA="set bridge \$DEVICE datapath_type=${osdm_ovs_datapath_type}"
ONBOOT=yes
BOOTPROTO=none
NOZEROCONF=yes
IPADDR=${_ip_info_ipaddr%%/*}
PREFIX=${_ip_info_ipaddr##*/}
GATEWAY=${_ip_info_gateway}
METRIC=${_ip_info_metric}
EOF

cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-${_patch1}
DEVICE=${_patch1}
DEVICETYPE=ovs
TYPE=OVSPatchPort
OVS_BRIDGE=${_br1}
OVS_OPTIONS="${_ovs_options}"
OVS_PATCH_PEER=${_patch2}
OVS_EXTRA=
EOF

cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-${_patch2}
DEVICE=${_patch2}
DEVICETYPE=ovs
TYPE=OVSPatchPort
OVS_BRIDGE=${_br2}
OVS_OPTIONS=
OVS_PATCH_PEER=${_patch1}
OVS_EXTRA=
EOF
}
export -f make_ovs_br_from_br


#  prepare_os_if \
#       "{{ osdm_node_nics_pro_if }}" \
#       {{ osdm_node_nics_pro_dedicated }} \
#       {{ osdm_os_pro_vlan }} \
#       {{ osdm_os_pro_if_addr }} \
#       {{ osdm_os_pro_gw }} \
#       {{ osdm_os_pro_metric }} \
#       {{ osdm_os_pro_if }} >> /var/log/set_ipaddr.log 2>&1

function prepare_os_if_neutron() {
    set -x
    _node_nics_x_if="$1"
    _node_nics_x_dedicated=$2
    _os_x_vlan=$3
    _os_x_if_addr=$4
    _os_x_if_gw=$5
    _os_x_if_metric=$6
    _os_x_if=$7

    _node_nics_x_if_list=($_node_nics_x_if)
    _node_nics_x_if_num=${#_node_nics_x_if_list[@]}

    ## osdm_team_type and osdm_team_mode are environment variables.
    if [[ $_node_nics_x_if_num -gt 1 ]]; then
        # not provide ip_info to `make_ovs_br_from_nics`
        make_ovs_br_from_nics "$_node_nics_x_if"                # ovsbr-eth0-eth1
        make_ovs_bondport $osdm_team_mode "$_node_nics_x_if"    # ovsbond-eth0-eth1
    else
        # not provide ip_info to `make_ovs_br_from_nics`
        make_ovs_br_from_nics "$_node_nics_x_if"        # ovsbr-eth0
        make_ovs_nicport "$_node_nics_x_if"      # (eth0)ovsport-eth0
    fi
    # If nics number > 1, like `eth0 eth1` -> ovsbr-eth0-eth1, ovsbond-eth0-eth1
    # If nics number = 1, like `eth0` -> ovsport-eth0, ovsbr-eth0

    # There's no ip addr information for all above interfaces.

    _node_nics_x_if=$(make_ovs_brname "$_node_nics_x_if")
    # From now on, the value of _node_nics_x_if is an ovs bridge like `ovsbr-eth0-eth1` or `ovsbr-eth0`

    #ip link set $_node_nics_x_if up

    _ip_info="$_os_x_if_addr $_os_x_if_gw $_os_x_if_metric"
    # For neutron, _os_x_if is an ovs bridge like: br-mgmt,br-ex,br-ten,br-pro,br-stor
    make_ovs_br_from_br "$_node_nics_x_if" $_os_x_if $_os_x_vlan "$_ip_info"
}
export -f prepare_os_if_neutron
