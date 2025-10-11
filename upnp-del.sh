#!/bin/sh

port="${1:-8080}"
proto="${2:-TCP}"

curl -s -X POST "http://192.168.1.1:52869/upnp/control/WANIPConn1" \
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
