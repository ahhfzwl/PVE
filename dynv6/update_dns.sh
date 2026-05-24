#!/bin/bash

if [ -z "$HOST" -o -z "$TOKEN" ]; then
  echo "HOST=cmsin.dynv6.net TOKEN=ddtVfZgfE19REdPwy2jThrfCm58URR ./update_dns.sh"
  exit 1
fi;

OLD=$(dig +short AAAA $HOST )
NEW=$(dig -6 TXT +short o-o.myaddr.l.google.com @ns1.google.com | tr -d '"')

if [ "$OLD" != "$NEW" ] ; then
  curl "http://ipv6.dynv6.com/api/update?hostname=$HOST&ipv6prefix=auto&token=$TOKEN"
fi
