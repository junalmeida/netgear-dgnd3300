#!/bin/sh
#  netgear-lease.sh
#
#  Created by Marcos Almeida Jr on 2012-04-19.
#  MIT License
#
#  Feature: Update hosts using dhcp leases


leases_file="/tmp/nbtscan.out"
hosts_file="/etc/hosts"


RestartDnrd() {
     dns=`cat /etc/resolv.conf`;IFS="
" set -- $dns;IFS=" " set -- $@;
     last_item=""
     dns_line=""
     for item in $@; do
          if [ "$last_item" = "nameserver" ]; then
               dns_line="$dns_line -s $item"
          fi
          last_item=$item
     done
     
     echo "$0: Restarting dnrd..." 
     killall -9 dnrd
     echo "dnrd -a $lan_ipaddr -m hosts -c off --timeout=0 -b $dns_line"
     dnrd -a $lan_ipaddr -m hosts -c off --timeout=0 -b $dns_line
}

eval `nvram get storage_machine_name`
eval `nvram get lan_ipaddr`
eval `nvram get lan_bipaddr`

IFS=. set -- $lan_bipaddr;IFS=" " set -- $1;lan_bipaddr="$1.$2.$3.0/24"
#echo "$0: nbtscan $lan_bipaddr" 
nbtscan $lan_bipaddr


leases=`cat $leases_file`
IFS="
" set -- $leases;leases=$@
IFS=";" set -- $leases;leases=$@
IFS=" " set -- $leases;leases=$@

count=0
last_ip=""
restart_dnrd="no"
for item in "$@"; do
    if [ "$count" = "0" ]; then last_ip=$item; fi
    if [ "$count" = "1" ]; then 
          already_set="no"
          if cat $hosts_file | grep $last_ip > /dev/null; then
               already_set="yes"
          fi

          if [ "$item" != "UNKNOWN" -a "$item" != "" -a "$already_set" = "no" ]; then
               echo ""
               echo ""
               echo ""
               echo ""
               echo "$0: found: $last_ip $item" 
               echo "$last_ip $item #set dinamically" >> $hosts_file
               restart_dnrd="yes"
          fi
    fi
 
    count=$(($count+1))
    if [ "$count" = "3" ]; then count=0; fi
done

if [ "$restart_dnrd" = "yes" ]; then
     #restarts dnrd to read hosts file.
     RestartDnrd
fi

exit 0
