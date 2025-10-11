#!/bin/sh

# ===== 参数与默认值 =====
port="${1:-8080}"       # 第一个参数：外部端口，默认8080
proto="${2:-TCP}"       # 第二个参数：协议，默认TCP
router_url="http://192.168.1.1:52869/upnp/control/WANIPConn1"  # 根据实际路由器修改

# ===== SOAP 请求体 =====
soap='<?xml version="1.0"?>
<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"
            s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
  <s:Body>
    <u:GetSpecificPortMappingEntry xmlns:u="urn:schemas-upnp-org:service:WANIPConnection:1">
      <NewRemoteHost></NewRemoteHost>
      <NewExternalPort>'"$port"'</NewExternalPort>
      <NewProtocol>'"$proto"'</NewProtocol>
    </u:GetSpecificPortMappingEntry>
  </s:Body>
</s:Envelope>'

# ===== 发送请求 =====
resp=$(curl -s -X POST "$router_url" \
  -H "Content-Type: text/xml; charset=utf-8" \
  -H 'SOAPAction: "urn:schemas-upnp-org:service:WANIPConnection:1#GetSpecificPortMappingEntry"' \
  -d "$soap")

# ===== 解析结果 =====
lease=$(echo "$resp" | grep -o '<NewLeaseDuration>[0-9]*</NewLeaseDuration>' | sed 's/[^0-9]//g')

if [ -n "$lease" ]; then
    if [ "$lease" = "0" ]; then
        echo "端口 ${port}/${proto} 的 UPnP 映射为永久有效（LeaseDuration=0）"
    else
        echo "端口 ${port}/${proto} 的 UPnP 映射有效期为 ${lease} 秒"
    fi
else
    echo "❌ 未找到端口 ${port}/${proto} 的 UPnP 映射或路由器未返回 LeaseDuration"
fi
