API_TOKEN=""
ZONE_ID=""
RECORD_ID=""
RECORD_NAME=""
TEST_DOMAIN=""
NS_SERVER="1.1.1.1"

PATH='/usr/sbin:/usr/bin:/sbin:/bin'

WAN_IP=`
	( \
		ubus call network.interface.wan status | \
		grep '"address":' | \
		grep -oE '[012]?\d?\d(\.[012]?\d?\d){3}' \
	) || {
		echo "Failed to retrieve WAN IP."
		exit 1
	}`

echo "WAN IP:     $WAN_IP"

CURRENT_IP=`
	( \
		nslookup $TEST_DOMAIN $NS_SERVER | \
		grep 'Address 1:' | \
		grep -oE '[012]?\d?\d(\.[012]?\d?\d){3}' \
	) || {
		echo "Failed to retrieve DNS record."
		exit 1
	}`

echo "Current IP: $CURRENT_IP"

if [ "$WAN_IP" == "$CURRENT_IP" ]; then
	echo "Needn't update."
	exit 0
fi

PART_1='{"type":"A","name":"'
PART_2='","content":"'
PART_3='","ttl":120,"proxied":false}'

curl -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
	-H "Authorization: Bearer $API_TOKEN" \
	-H "Content-Type: application/json" \
	--data "${PART_1}${RECORD_NAME}${PART_2}${WAN_IP}${PART_3}" 2> /dev/null | grep '"success":true' > /dev/null || {
		echo "Unknown error."
		exit 1
	}

echo "Task completed!"
