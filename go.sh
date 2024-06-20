#!/bin/bash
SUDO=sudo

if [[ $USER == "root" ]]; then SUDO=""; fi

echo 1 | $SUDO tee /proc/sys/net/ipv4/ip_forward
echo "net.ipv4.ip_forward = 1" | $SUDO tee -a /etc/sysctl.conf
$SUDO iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

MY_IP=curl -4 icanhazip.com
echo Server is at $MY_IP

docker run -v /vpn:/etc/openvpn --rm kylemanna/openvpn ovpn_genconfig -u udp://$MY_IP
docker run -v /vpn:/etc/openvpn --rm -it kylemanna/openvpn ovpn_initpki
docker run -v /vpn:/etc/openvpn -d -p 1194:1194/udp --cap-add=NET_ADMIN kylemanna/openvpn
docker run -v /vpn:/etc/openvpn --rm -it kylemanna/openvpn easyrsa build-client-full quick_vpn nopass
docker run -v /vpn:/etc/openvpn --rm kylemanna/openvpn ovpn_getclient quick_vpn > quick_vpn.ovpn

echo Client config file saved to quick_vpn.ovpn.
