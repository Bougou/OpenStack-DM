#!/usr/bin/env python

import sys
import ipaddress
import struct
import socket

# org_addr (original ip address)
# an ip address, 172.30.1.15
# if prefix or mask is also provided, it is ignored

# new_netrange: a network range 172.30.2.0/24
# only network part is meaningful

def generate_new_addr(org_addr, new_netrange):
    org = ipaddress.IPv4Interface(org_addr)
    # u'172.30.1.15'
    org_ip = org.ip
    org_ip_bin = struct.unpack("!L", org_ip.packed)[0]

    #
    # These two procedures mean to get a pure network address
    #

    # new_netrange = u'172.30.2.100/24'
    _new = ipaddress.IPv4Interface(new_netrange)
    # _new_network = u'172.30.2.0/24'
    _new_network = _new.network

    new = ipaddress.IPv4Interface(_new_network)

    # new_netip = u'172.30.2.0'
    new_netip = new.ip
    # new_mask = u'0.0.0.255'
    new_mask = new.hostmask
    new_mask_bin = struct.unpack("!L", new_mask.packed)[0]
    new_netip_bin = struct.unpack("!L", new_netip.packed)[0]

    # because origin ip address does not provide mask info
    #  0.0.0.5       = 172.30.1.5 & 0.0.0.255
    org_hostonly_bin = org_ip_bin & new_mask_bin

    # 172.30.2.5 = 172.30.2.0 | 0.0.0.5
    new_ip_bin = new_netip_bin | org_hostonly_bin
    new_ip = socket.inet_ntoa(struct.pack("!L", new_ip_bin))

    new_prefix = new.network.prefixlen
    new_addr = new_ip + '/' + str(new_prefix)
    return new_addr

if __name__ == '__main__':
    org_addr = unicode(sys.argv[1])
    new_netrange = unicode(sys.argv[2])

    new = ipaddress.IPv4Interface(new_netrange)
    if new.network.prefixlen == 32:
        sys.exit(1)

    new_addr = generate_new_addr(org_addr, new_netrange)

    # 172.30.10.81/24
    print new_addr
