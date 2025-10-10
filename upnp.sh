#!/bin/sh
Public_addr="$1"
Public_port="$2"
IP4P="$3"
Bind_port="$4"
Protocol="$5"
Private_addr="$6"
Private_port="80"

router_url="http://192.168.1.1:52869/upnp/control/WANIPConn1"

curl -s -X POST "$router_url" \
     -H "Content-Type: text/xml; charset=utf-8" \
     -H "SOAPAction: \"urn:schemas-upnp-org:service:WANIPConnection:1#AddPortMapping\"" \
     -d "<?xml version=\"1.0\"?>
<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\" s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
  <s:Body>
    <u:AddPortMapping xmlns:u=\"urn:schemas-upnp-org:service:WANIPConnection:1\">
      <NewRemoteHost></NewRemoteHost>
      <NewExternalPort>${Bind_port}</NewExternalPort>
      <NewProtocol>${Protocol^^}</NewProtocol>
      <NewInternalPort>${Private_port}</NewInternalPort>
      <NewInternalClient>${Private_addr}</NewInternalClient>
      <NewEnabled>1</NewEnabled>
      <NewPortMappingDescription>Manual-UPnP</NewPortMappingDescription>
      <NewLeaseDuration>0</NewLeaseDuration>
    </u:AddPortMapping>
  </s:Body>
</s:Envelope>"
