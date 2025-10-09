protocol="$1"
private_ip="$2"
private_port="$3"
public_ip="$4"
public_port="$5"

 curl -X POST -d "json={\"listen_port\":$public_port}" -H "Content-Type: application/x-www-form-urlencoded" "http://127.0.0.1:9090/api/v2/app/setPreferences"

curl -X POST -H "Content-Type: text/xml; charset=utf-8" \
                        -H "SOAPAction: \"urn:schemas-upnp-org:service:WANIPConnection:1#AddPortMapping\"" \
                        -H "User-Agent: curl/8.0.0 (Natter)" \
                        -H "Host: 192.168.5.1:52869" \
                        -H "Accept: */*" \
                        -H "Connection: close" \
                        -d "<?xml version=\"1.0\" encoding=\"utf-8\"?>
<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\"
  s:encodingStyle=\"http://schemas.xmlsoap.org/soap/encoding/\">
  <s:Body>
    <m:AddPortMapping xmlns:m=\"urn:schemas-upnp-org:service:WANIPConnection:1\">
      <NewRemoteHost></NewRemoteHost>
      <NewExternalPort>$private_port</NewExternalPort>
      <NewProtocol>$protocol</NewProtocol>
      <NewInternalPort>$public_port</NewInternalPort>
      <NewInternalClient>$private_ip</NewInternalClient>
      <NewEnabled>1</NewEnabled>
      <NewPortMappingDescription>qbittorrent</NewPortMappingDescription>
      <NewLeaseDuration>604800</NewLeaseDuration>
    </m:AddPortMapping>
  </s:Body>
</s:Envelope>" "http://192.168.5.1:52869/upnp/control/WANIPConn1"
