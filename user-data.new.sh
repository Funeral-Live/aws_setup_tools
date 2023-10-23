#!/bin/bash
apt update -y
apt install openvpn -y
 
mkdir -p /var/log/openvpn
mkdir /etc/openvpn/ccd
mkdir /etc/scripts

#groupadd nogroup
useradd nogroup -g nogroup

cd /etc/scripts/
sudo wget https://github.com/Funeral-Live/aws_setup_tools/raw/main/start-streaming.sh
sudo wget https://github.com/Funeral-Live/aws_setup_tools/raw/main/stop-streaming.sh
chmod +x start-streaming.sh
chmod +x stop-streaming.sh

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

# You will may have to change eth0 to the interface name that you have
iptables -F
iptables -t nat -F
iptables -A FORWARD -i eth0 -o tun0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s 10.10.20.0/24 -o eth0 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.10.20.0/24 ! -d 10.10.20.0/24 -o eth0 -j MASQUERADE

#Make IPtables rules persistent (after reboots)
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt -y install iptables-persistent
iptables-save > /etc/iptables/rules.v4

#Create bulk vpn users:

#Build vpn users:
for i in $(seq --format "%04g" 2001 2100)
do
  echo "vpnuser-$i"":vPn-US3r-$i"":$i:$i::/home/vpnuser-$i:/bin/false" >> vpn_users.txt
done

chmod 0600 vpn_users.txt

newusers vpn_users.txt

#Add remote Mikrotik LAN CIDR by each user:

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
#systemctl status openvpn@server
#
#Install gstreamer
apt install libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio -y
#End Script
