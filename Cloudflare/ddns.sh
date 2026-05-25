#!/bin/sh -e

# 检查参数
if [ $# -ne 3 ]; then
    echo "Usage: $0 <zone_id> <api_token> <domain>"
    echo "Example: $0 abc123 def456 mydomain.example.com"
    exit 1
fi

ZONE=$1
TOKEN=$2
DOMAIN=$3
CACHE="/tmp/$DOMAIN"
[ -f "$CACHE" ] && OLD=$(cat "$CACHE")

# 获取当前IPv6
NEW=$(curl -6 -s test.ipw.cn)
[ -z "$NEW" ] && echo "No new IP found" && exit 1

# IP未变化则退出
[ "$OLD" = "$NEW" ] && echo "$(date) $NEW unchanged" && exit 0

# 获取记录ID
ID=$(curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE/dns_records?type=AAAA&name=$DOMAIN" -H "Authorization: Bearer $TOKEN" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

[ -z "$ID" ] && echo "ID not found" && exit 1

# 更新记录
DATA='{"type":"AAAA","name":"'"$DOMAIN"'","content":"'"$NEW"'","ttl":1,"proxied":false}'
STATUS=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE/dns_records/$ID" -H "Authorization: Bearer $TOKEN" -H "Content-Type:application/json" -d "$DATA" | grep -o '"success":[a-z]*' | cut -d':' -f2)

if [ "$STATUS" = "true" ]; then
    echo "$NEW" > "$CACHE"
    echo "$(date) $NEW updated"
else
    echo "$(date) update failed"
fi
