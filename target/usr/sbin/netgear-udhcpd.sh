#!/bin/sh
#  netgear-udhcpd.sh
#
#  Created by Marcos Almeida Jr on 2012-04-19.
#  MIT License
#
#  Feature: Local dns server for leased ips.
conf_file=/etc/udhcpd.conf
leases_file=/var/udhcpd.leases
leases_tmp_file=/tmp/udhcpd.leases

 
eval `nvram get dhcp_server_enable`
if [ "$dhcp_server_enable" = "1" ]; then
     #only when dhcp server is on
     if cat $conf_file | grep leases_file >/dev/null; then
          exit 0
     else
          eval `nvram get lan_ipaddr`
          eval `nvram get dhcp_start_ip`
          eval `nvram get dhcp_end_ip`
          eval `nvram get lan_if`
          eval `nvram get lan_netmask`

          echo "server          $lan_ipaddr
start           $dhcp_start_ip
end             $dhcp_end_ip
interface       $lan_if
option  subnet  $lan_netmask
option  router  $lan_ipaddr
option  dns     $lan_ipaddr
option  lease   86400
leases_file	 $leases_file" > $conf_file

          echo ""
          echo ""
          echo ""
          echo "$0: udhcpd configuration changed."
          
          pid=`ps | grep "udhcpd $conf_file" | grep -v grep`;
          IFS=" " set -- $pid;pid=$1;
          
          dhcp_reserved=`nvram get dhcp_reserved`
          echo "$0: reserved ips: $dhcp_reserved"
          #keep the reservation file
          #for some reason this file sometimes is empty
          if [ "$dhcp_reserved" != "dhcp_reserved=" ]; then
               while true; do 
                    leases=""
		    cp $leases_file $leases_tmp_file
                    leases=`cat $leases_tmp_file`
                    if [ "$leases" != "" ] ; then 
                         kill -9 $pid
                         echo "killed udhcpd pid:$pid"
			 cp $leases_tmp_file $leases_file
                         /usr/sbin/udhcpd $conf_file &
                         break
                    fi
               done
          else
               kill -9 $pid
               echo "killed udhcpd pid:$pid"
               /usr/sbin/udhcpd $conf_file &
          fi
     fi
fi

exit 0
