#!/bin/sh -e
zone=$1
token=$2
domain=$3
[ -e /tmp/$domain ] && old=$(cat /tmp/$domain)
cloudflaredns(){
    id=$(curl -s "https://api.cloudflare.com/client/v4/zones/$zone/dns_records" -H "Authorization: Bearer $token" | sed -e 's/"id"/\n/g' | grep -w "AAAA" | grep "\"name\":\"$domain\"" | awk -F\" '{print $2}')
	if [ -z "$id" ]; then
		echo "ID not found"
	else
		status=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zone/dns_records/$id" -H "Authorization: Bearer $token" -H "Content-Type:application/json" -d '{"type":"'"AAAA"'","name":"'"$domain"'","content":"'"$new"'","ttl":1,"proxied":false}' | sed 's/.*"success":\([a-z]\+\).*/\1/')
		if [ "$status" = "true" ]; then
			echo $new > /tmp/$domain
		fi
		echo "$(date) $new $status"
	fi
}
new=$(curl -6 test.ipw.cn)
if [ -z "$new" ]; then
	echo "No new IP found"
elif [ "$old" = "$new" ]; then
	echo "$(date) $new IP address unchanged"
else
	cloudflaredns $new
fi
