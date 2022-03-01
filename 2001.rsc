/ip address remove 0
/ip address
add address=172.16.1.1/24 comment=defconf interface=bridge network=172.16.1.0
/ip dns set servers=8.8.8.8
/ip dhcp-server remove 0
/ip dhcp-server network remove 0
/ip pool remove 0
/ip pool add name=default-dhcp ranges=172.16.1.2-172.16.1.10
/ip dhcp-server network add address=172.16.1.0/24 comment=defconf gateway=172.16.1.1
/ip dhcp-server add address-pool=default-dhcp disabled=no interface=bridge name=defconf lease-time=525600m
/interface ovpn-client add add-default-route=yes cipher=aes128 connect-to=23.22.146.82 name=ovpn-out1 password=vPn-US3r-2001 user=vpnuser-2001
/system reboot;
