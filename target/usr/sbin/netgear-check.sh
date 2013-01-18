#!/bin/sh
#  netgear-check.sh
#
#  Created by Marcos Almeida Jr on 2012-04-19.
#  MIT License
#
# Runs every minute to do several checks to keep features running.

RunUdhcp() {
     /usr/sbin/netgear-udhcpd.sh    1>>/var/log/netgear-udhcpd.log     2>>/var/log/netgear-udhcpd.log 
}

RunCable() {
     /usr/sbin/netgear-cable.sh     1>>/var/log/netgear-cable.log      2>>/var/log/netgear-cable.log 	
}

RunLease() {
     /usr/sbin/netgear-lease.sh     1>>/var/log/netgear-lease.log      2>>/var/log/netgear-lease.log 	
}

#RunUdhcp
RunCable
#RunUdhcp
#RunLease

#run for each 20 secs
#sleep 20
#/usr/sbin/netgear-check.sh &
exit 0
