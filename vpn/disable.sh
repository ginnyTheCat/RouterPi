sudo systemctl disable openvpn@client.service
sudo systemctl stop openvpn@client.service
sudo iptables-restore </etc/iptables4.normal
