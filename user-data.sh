#!/bin/bash
yum update -y
amazon-linux-extras install epel -y
yum -y install openvpn
 
mkdir -p /var/log/openvpn
mkdir /etc/openvpn/ccd

groupadd nogroup
useradd nogroup -g nogroup

cd /etc/openvpn/server/
wget https://github.com/Funeral-Live/aws_setup_tools/raw/main/openssl.cnf
wget https://github.com/Funeral-Live/aws_setup_tools/raw/main/generate-key.sh
chmod +x generate-key.sh
./generate-key.sh

cd /etc/openvpn/
wget https://github.com/Funeral-Live/aws_setup_tools/raw/main/server.conf

systemctl start openvpn@server
systemctl enable openvpn@server
#systemctl status openvpn@server

#Add network settings as root:

echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# Make Iptables rules persistent (after reboots)
yum install -y iptables-services
systemctl enable iptables
service iptables start

# You will may have to change eth0 to the interface name that you have
iptables -F
iptables -t nat -F
iptables -A FORWARD -i eth0 -o tun0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s 10.10.20.0/24 -o eth0 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.10.20.0/24 ! -d 10.10.20.0/24 -o eth0 -j MASQUERADE

service iptables save

#Create bulk vpn users:

#Build vpn users:
for i in $(seq --format "%04g" 2001 2100)
do
  echo "vpnuser-$i"":vPn-US3r-$i"":$i:$i::/home/vpnuser-$i:/bin/false" >> vpn_users.txt
done

chmod 0600 vpn_users.txt

newusers vpn_users.txt

#Add remote Mikrotik LAN CIDR by each user:

#!/bin/bash
cd /etc/openvpn/ccd

i=1
b=2001
while [ $i -lt 101 ]
do
echo iroute 172.16.$i.0 255.255.255.0 > vpnuser-$b
(( i = $i + 1 ))
(( b = $b + 1 ))
done

systemctl restart openvpn@server

#
#End Script
