#!/bin/sh -e
hostname=$1
device=$2
file=$HOME/.dynv6.addr6
[ -e $file ] && old=`cat $file`
if [ -z "$hostname" -o -z "$token" ]; then
  echo "Usage: token=<your-authentication-token> [netmask=64] $0 your-name.dynv6.net [device]"
  exit 1
fi
if [ -z "$netmask" ]; then
  netmask=64
fi
if [ -n "$device" ]; then
  device="dev $device"
fi
address=$(ip -6 addr list scope global $device | grep -v " fd" | sed -n 's/.*inet6 \([0-9a-f:]\+\).*/\1/p' | head -n 1)
if [ -e /usr/bin/curl ]; then
  bin="curl -fsS"
elif [ -e /usr/bin/wget ]; then
  bin="wget -O-"
else
  echo "neither curl nor wget found"
  exit 1
fi
if [ -z "$address" ]; then
  echo "no IPv6 address found"
  exit 1
fi
current=$address/$netmask
if [ "$old" = "$current" ]; then
  echo "IPv6 address unchanged"
  exit
fi
$bin "http://dynv6.com/api/update?hostname=$hostname&ipv6prefix=auto&token=$token"
echo $current > $file
