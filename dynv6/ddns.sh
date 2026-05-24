#!/bin/sh -e
HOST=$1
FILE=$HOME/.dynv6.addr6
[ -e $FILE ] && OLD=`cat $FILE`
if [ -z "$HOST" -o -z "$TOKEN" ]; then
  echo "TOKEN=ddtVfZgfE19REdPwy2jThrfCm58URR ./dynv6.sh tunnels.dynv6.net"
  exit 1
fi
NEW=$(ip -6 addr list scope global $device | grep -v " fd" | sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | head -n 1)
if [ "$OLD" = "$NEW" ]; then
  echo "IPv6 address unchanged"
  exit
fi
curl -fsS "http://dynv6.com/api/update?hostname=$HOST&ipv6prefix=auto&token=$TOKEN"
echo $NEW > $file
