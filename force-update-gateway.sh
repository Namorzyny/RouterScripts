PATH='/usr/sbin:/usr/bin:/sbin:/bin'

ubus call network.interface.wan status | grep '"up": true,' > /dev/null 2>&1 && {
	route | grep default > /dev/null 2>&1 || {
		V4_GW=`route | grep 'pppoe' | awk '{print $1}'`
		route add default gw $V4_GW
		echo "IPv4 gateway updated: $V4_GW"
	}
}

ubus call network.interface.wan6 status | grep '"code": "NO_DEVICE"' > /dev/null 2>&1 || {
	ubus call network.interface.wan6 status | grep '"up": true,' > /dev/null 2>&1 && {
		ip -6 route | grep 'default via' > /dev/null 2>&1 || {
			V6_GW=`ubus call network.interface.wan6 status | grep nexthop | awk -F '"' '{print $4}'`
			ip -6 route add default via $V6_GW dev pppoe-wan
			echo "IPv6 gateway updated: $V6_GW"
		}
	}
}
