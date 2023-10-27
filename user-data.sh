#!/bin/bash

mkdir /etc/scripts/

#streaming script
cd /etc/scripts/
sudo wget https://github.com/Funeral-Live/aws_setup_tools/raw/main/start-streaming.sh
sudo wget https://github.com/Funeral-Live/aws_setup_tools/raw/main/stop-streaming.sh
chmod +x start-streaming.sh
chmod +x stop-streaming.sh

#Install and configure wireguard
sudo apt update
sudo apt install wireguard
cd /etc/wireguard
wg genkey | sudo tee /etc/wireguard/private.key
sudo chmod go= /etc/wireguard/private.key
privkey=$(cat /etc/wireguard/private.key)
cat > /etc/wireguard/wg0.conf <<- EOM
[Interface]
PrivateKey = $privkey
Address = 10.10.20.1/24
ListenPort = 51820
#SaveConfig = true
PostUp = ufw route allow in on wg0 out on ens33
PostUp = iptables -t nat -I POSTROUTING -o ens33 -j MASQUERADE
PostUp = ip6tables -t nat -I POSTROUTING -o ens33 -j MASQUERADE
PreDown = ufw route delete allow in on wg0 out on ens33
PreDown = iptables -t nat -D POSTROUTING -o ens33 -j MASQUERADE
PreDown = ip6tables -t nat -D POSTROUTING -o ens33 -j MASQUERADE
EOM

#Add peers
END=50
for ((i=1;i<=END;i++)); do
        ip=$((50+$i))
        privkey=$(wg genkey)
        echo $privkey >> privkeys.txt
        echo $privkey | wg pubkey >> pubkeys.txt
        pubkey=$(echo $privkey | wg pubkey)
#       echo $pubkey
#       echo $ip
        cat >> /etc/wireguard/wg0.conf <<- EOM
[Peer]
PublicKey = $pubkey
AllowedIPs = 10.10.20.$ip/32,172.16.$ip.0/24

EOM
done

#Restart wireguard
sudo systemctl restart wg-quick@wg0.service

#Add network settings as root:
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p

# You will may have to change eth0 to the interface name that you have
iptables -F
iptables -t nat -F
iptables -A FORWARD -i eth0 -o tun0 -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -s 10.10.20.0/24 -o ens33 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.10.20.0/24 ! -d 10.10.20.0/24 -o ens33 -j MASQUERADE

#Make IPtables rules persistent (after reboots)
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
apt -y install iptables-persistent
iptables-save > /etc/iptables/rules.v4

#Install gstreamer
apt install libgstreamer1.0-0 gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio -y
#End Script
