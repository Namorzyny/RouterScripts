#!/bin/sh /etc/rc.common

gen_script_name() {
	echo "wwan_$( \
		uci show wireless.wifinet1.ssid | \
		awk '{print tolower(substr($0, 24))}' | \
		awk '{print substr($0, 2, length - 2)}' | \
		sed 's/\W/_/g'
	)"
}

write_script() {
	SCRIPT_NAME=/etc/init.d/$(gen_script_name)
	chmod 755 $SCRIPT_NAME
	echo "#!/bin/sh /etc/rc.common" > $SCRIPT_NAME
	echo "START=99" >> $SCRIPT_NAME
	echo "STOP=99" >> $SCRIPT_NAME
	echo "stop() {return 0}" >> $SCRIPT_NAME
	echo "start() {" >> $SCRIPT_NAME
	echo "	uci delete wireless.wifinet1" >> $SCRIPT_NAME
	uci show wireless.wifinet1 | while read line
	do
		echo "	uci set ${line}" >> $SCRIPT_NAME
	done
	echo "	uci commit" >> $SCRIPT_NAME
	echo "}" >> $SCRIPT_NAME
}

START=99
STOP=99

start() {
	write_script
}

stop() {return 0}
