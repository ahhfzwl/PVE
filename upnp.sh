#!/bin/sh

# 参数与默认值
Public_addr="${1:-104.16.0.1}"    # 默认公网地址（如果需要可改）
Public_port="${2:-80}"             # 默认外部端口
IP4P="${3:-2001::50:6810:1}"           # 默认内网IP
Bind_port="${4:-8}"               # 默认绑定端口
Protocol="${5:-TCP}"                 # 默认协议
Private_addr="${6:-192.168.1.200}"   # 默认私网地址
Private_port="${7:-80}"              # 默认私网端口
router_url="${8:-http://192.168.1.1:52869/upnp/control/WANIPConn1}" # 默认路由器UPnP控制URL

# 执行UPnP添加端口映射
curl -s -X POST "$router_url" \
     -H "Content-Type: text/xml; charset=utf-8" \
     -H "SOAPAction: \"urn:schemas-upnp-org:service:WANIPConnection:1#AddPortMapping\"" \
     -d "<?xml version=\"1.0\"?>
<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
  <s:Body>
    <u:AddPortMapping xmlns:u=\"urn:schemas-upnp-org:service:WANIPConnection:1\">
      <NewRemoteHost></NewRemoteHost>
      <NewExternalPort>${Bind_port}</NewExternalPort>
      <NewProtocol>$(echo "$Protocol" | tr 'a-z' 'A-Z')</NewProtocol>
      <NewInternalPort>${Private_port}</NewInternalPort>
      <NewInternalClient>${Private_addr}</NewInternalClient>
      <NewEnabled>1</NewEnabled>
      <NewPortMappingDescription>Manual-UPnP</NewPortMappingDescription>
      <NewLeaseDuration>0</NewLeaseDuration>
    </u:AddPortMapping>
  </s:Body>
</s:Envelope>"
