#!/bin/sh

# 传参与默认值
port="${1:-8080}"       # 第一个参数：外部端口，默认 8080
proto="${2:-TCP}"       # 第二个参数：协议，默认 TCP
router_url="http://192.168.1.1:52869/upnp/control/WANIPConn1"   # 根据你的路由器实际修改

# 执行删除请求
curl -s -X POST "$router_url" \
  -H "Content-Type: text/xml; charset=utf-8" \
  -H 'SOAPAction: "urn:schemas-upnp-org:service:WANIPConnection:1#DeletePortMapping"' \
  -d "<?xml version=\"1.0\"?>
  <s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\"
              s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
    <s:Body>
      <u:DeletePortMapping xmlns:u=\"urn:schemas-upnp-org:service:WANIPConnection:1\">
        <NewRemoteHost></NewRemoteHost>
        <NewExternalPort>${port}</NewExternalPort>
        <NewProtocol>${proto}</NewProtocol>
      </u:DeletePortMapping>
    </s:Body>
  </s:Envelope>"
