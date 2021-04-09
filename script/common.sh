#!/usr/bin/env bash

set -Eeuo pipefail

# Set VM variables
DISTRO="ubuntu"
POOL_NAME="ubuntu-pool"
HOST_COUNT="3"
INTERFACE="ens01"
MEMORY="2048"
VCPU="2"
IP_BASE="192.168.122.100"
HOST_BASE="node"
HOST_NAMES=""
HOST_IPS=""
MAC_ADDRS=""

# Generate a range of Host names, IP addresses and MAC addresses
startnum=$(echo $IP_BASE | awk -F. '{ print $4 }')
endnum=$((startnum+HOST_COUNT-1))
networkip=$(echo $IP_BASE |awk -F. '{ print $1"."$2"."$3 }')


if [[ $startnum -gt $endnum || $endnum -gt 255 ]]; then
    echo "The IP addresses are out of the range!"
    exit 1
fi

for (( i=0; i<HOST_COUNT; i++ )); do
    next_host=$HOST_BASE$i
    next_ip=$networkip"."$((startnum+i))
    next_mac=$(printf '52:54:00:%02x:%02x:%02x' $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
    if [[ $i -eq 0 ]]; then
        HOST_NAMES='"'$next_host'"'
        HOST_IPS='"'$next_ip'"'
        MAC_ADDRS='"'$next_mac'"'
    else
        HOST_NAMES=$HOST_NAMES","'"'$next_host'"'
        HOST_IPS=$HOST_IPS","'"'$next_ip'"'
        MAC_ADDRS=$MAC_ADDRS","'"'$next_mac'"'
    fi
  
done

HOST_NAMES="["$HOST_NAMES"]"
HOST_IPS="["$HOST_IPS"]"
MAC_ADDRS="["$MAC_ADDRS"]"

# Set environment variables
export DISTRO=$DISTRO
export POOL_NAME=$POOL_NAME
export HOST_COUNT=$HOST_COUNT
export INTERFACE=$INTERFACE
export MEMORY=$MEMORY
export VCPU=$VCPU
export HOST_NAMES=$HOST_NAMES
export HOST_IPS=$HOST_IPS
export MAC_ADDRS=$MAC_ADDRS
