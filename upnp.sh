#!/bin/sh
Public_addr="${1:-104.16.0.1}"
Public_port="${2:-80}"
IP4P="${3:-2001::50:6810:1}"
Bind_port="${4:-8}"
Protocol="${5:-TCP}"
Private_addr="${6:-192.168.1.200}"
Private_port="${7:-80}"
router_url="${8:-http://192.168.1.1:52869/upnp/control/WANIPConn1}"
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
echo "${Public_addr}:${Public_port}" > /tmp/natmap.log
echo "${Public_addr}:${Public_port}"
