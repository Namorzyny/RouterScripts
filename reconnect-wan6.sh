PATH='/usr/sbin:/usr/bin:/sbin:/bin'

ubus call network.interface.wan status | grep '"up": true,' > /dev/null 2>&1 || {
	echo "PPPoE is down."
	exit 1
}

has_error=0

ubus call network.interface.wan6 status | grep '"code": "NO_DEVICE"' > /dev/null 2>&1 && has_error=1
ubus call network.interface.wan6 status | grep '"up": true,' > /dev/null 2>&1 || has_error=1

if [ $has_error -eq 0 ]; then
	echo "Nothing to do."
	exit 0
fi

echo "Switching settings..."
uci set network.wan6.reqaddress='disabled'
uci commit
ifdown wan6
ifup wan6

echo "Applying..."
sleep 5s

echo "Rolling back settings..."
uci set network.wan6.reqaddress='try'
uci commit
ifdown wan6
ifup wan6

echo "Waiting..."
sleep 10s

ubus call network.interface.wan6 status | grep '"up": true,' > /dev/null 2>&1 || {
	echo "WAN6 is up."
	exit 0
}

echo "Failed."
exit 1
