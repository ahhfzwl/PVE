#!/bin/sh

if [ -z "$HOST" ] || [ -z "$TOKEN" ]; then
    echo "HOST=cmsin.dynv6.net TOKEN=ddtVfZgfE19REdPwy2jThrfCm58URR ./update_dns.sh"
    exit 1
fi

OLD=$(dig +short AAAA "$HOST")
NEW=$(dig -6 TXT +short o-o.myaddr.l.google.com @ns1.google.com | tr -d '"')

if [ -z "$NEW" ]; then
    echo "Failed to get current IPv6 address"
    exit 1
fi

if [ "$OLD" != "$NEW" ]; then
    # 加上 /64 前缀
    curl "http://ipv6.dynv6.com/api/update?hostname=$HOST&ipv6=${NEW}/64&token=$TOKEN"
else
    echo "IP unchanged: $OLD"
fi
