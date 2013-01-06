#!/bin/sh

#  netgear-check.sh
#
#  Created by Marcos Almeida Jr on 2012-04-19.
#  MIT License
#
# Runs every minute to do several checks to keep features running.

RunUdhcp() {
     /usr/etc/netgear-udhcpd.sh    1>>/var/log/netgear-udhcpd.log     2>>/var/log/netgear-udhcpd.log 
}

RunCable() {
     /usr/etc/netgear-cable.sh     1>>/var/log/netgear-cable.log      2>>/var/log/netgear-cable.log 	
}

RunLease() {
     /usr/etc/netgear-lease.sh     1>>/var/log/netgear-lease.log      2>>/var/log/netgear-lease.log 	
}

RunChecks() {
     RunCable
     RunUdhcp
     RunLease
     
     #run for each 10 secs
     sleep 10
     RunChecks
}

RunUdhcp
RunChecks
exit 0
