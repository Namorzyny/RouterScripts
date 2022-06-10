if uci show wireless.wifinet1 | grep "wireless.wifinet1.disabled='1'"; then
	echo "WWAN is already disabled."
	exit
fi

if ifstatus wwan | grep '"up": true,'; then
	echo "WWAN is working normally."
	exit
fi

echo "WWAN does not work, disabling..."
uci set wireless.wifinet1.disabled='1'
uci commit wireless.wifinet1.disabled
/etc/init.d/network reload
