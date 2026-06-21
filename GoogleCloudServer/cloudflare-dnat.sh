#!/bin/bash
#curl -s https://raw.githubusercontent.com/ahhfzwl/PVE/main/GoogleCloudServer/cloudflare-dnat.sh | sudo bash -s -- 64.186.225.82
TARGET_IP=${1:-"64.186.225.82"}
CF_IP_LIST="/tmp/cf_ips.txt"

if [ "$1" != "" ]; then
    echo "切换到新 IP: $TARGET_IP"
fi

curl -s https://www.cloudflare.com/ips-v4 -o $CF_IP_LIST

sudo iptables -t nat -F CLOUDFLARE_DNAT 2>/dev/null

if ! sudo iptables -t nat -L CLOUDFLARE_DNAT &>/dev/null; then
    sudo iptables -t nat -N CLOUDFLARE_DNAT
    sudo iptables -t nat -A OUTPUT -j CLOUDFLARE_DNAT
fi

while read ip; do
    if [ "$ip" != "$TARGET_IP" ]; then
        sudo iptables -t nat -A CLOUDFLARE_DNAT -d $ip -p tcp -j DNAT --to-destination $TARGET_IP
    fi
done < $CF_IP_LIST

echo "✅ Cloudflare DNAT 已更新，目标 IP: $TARGET_IP"
