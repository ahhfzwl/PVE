#!/bin/sh

protocol="${1:-TCP}"
internal_ip="${2:-192.168.1.200}"
internal_port="${3:-80}"
external_port="${4:-8080}"
router_url="http://192.168.1.1:52869/upnp/control/WANIPConn1"

echo "[*] 发送UPnP端口映射请求..."
curl -s -X POST -H "Content-Type: text/xml; charset=utf-8" \
     -H "SOAPAction: \"urn:schemas-upnp-org:service:WANIPConnection:1#AddPortMapping\"" \
     -d "<?xml version=\"1.0\"?>
<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\"
            s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
  <s:Body>
    <m:AddPortMapping xmlns:m=\"urn:schemas-upnp-org:service:WANIPConnection:1\">
      <NewRemoteHost></NewRemoteHost>
      <NewExternalPort>${external_port}</NewExternalPort>
      <NewProtocol>${protocol}</NewProtocol>
      <NewInternalPort>${internal_port}</NewInternalPort>
      <NewInternalClient>${internal_ip}</NewInternalClient>
      <NewEnabled>1</NewEnabled>
      <NewPortMappingDescription>Manual-UPnP</NewPortMappingDescription>
      <NewLeaseDuration>0</NewLeaseDuration>
    </m:AddPortMapping>
  </s:Body>
</s:Envelope>" \
     "${router_url}"
echo
echo "[*] 完成"
