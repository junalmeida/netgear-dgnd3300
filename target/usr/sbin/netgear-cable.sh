#!/bin/sh
#  netgear-cable.sh
#
#  Created by Marcos Almeida Jr on 2012-04-19.
#  MIT License
#
#
#  Convert Netgear DGND3300 Ethernet port into a WAN port
#  Useful to move from ADSL to Cable provider
#
#
#  README-FIRST
#  Open web admin and set the following:
#  > Basic Settings
#      > Does Your Internet Connection Require A Login?
#         NO
#      > Internet IP Address
#         Get Dynamically
#      > NAT
#         ON
new_wan=br2
new_wan_port=eth0.5
#network base address of many cable modem
cm_net=192.168.100.0 
eval `nvram get lan_netmask`

Test() {
     sleep 5
     killall udhcpc
     ## Check for an internet connection, hope google does not goes down.    

     if [ "$(wget -q -O- http://google.com)" != "" ]; then
          internet="yes"
     else
          internet="no"
     fi

     if [ "$internet" = "no" ]; then
	  echo ""
	  echo ""
          echo "$0: Internet is not connected. Retry..."
          Execute
	  Test
     else
	  echo ""
	  echo ""
          echo "$0: Internet is connected."
     fi
}

Execute() {
     eval `nvram get wan_ifname`
     eval `nvram get lan_if`
     eval `nvram get wan_mode`

     if [ "$wan_mode" = "dhcpc" ]; then
          convert="yes"

          if brctl show | grep $new_wan >/dev/null ; then 
               convert="no" 
               if [ "$new_wan" != "$wan_ifname" ]; then
                    convert="yes"
               fi
          fi

          if [ "$convert" = "yes" ]; then
	       echo ""
	       echo ""
               echo "$0: Converting first ethernet port into wan."

               brctl delif $lan_if $new_wan_port 2>/dev/null
               brctl addbr $new_wan 2>/dev/null
               brctl addif $new_wan $new_wan_port 2>/dev/null

               #add cable modem route to access its config web page
               route add -net $cm_net netmask $lan_netmask $new_wan

               #tell router that our wan changed
               nvram set wan_ifname=$new_wan

               #kill previous connect attemps
               killall udhcpc	

               #go go go
               echo "$0: Trying to get ip from cable modem..."
               /usr/sbin/udhcpc -i $new_wan -s /usr/etc/udhcpc.script &
          fi
     else
          if brctl show | grep $new_wan >/dev/null ; then 
               #undo only if the new bridge exists
               #undo any changes
               ifconfig $new_wan down
               brctl delif $new_wan $new_wan_port
               brctl delbr $new_wan
               brctl addif $lan_if $new_wan_port
               ifconfig $new_wan_port up
	       echo ""
	       echo ""
               echo "$0: ADSL restored."
          fi
     fi
}
Execute
Test

exit 0

