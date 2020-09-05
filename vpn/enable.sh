cd /etc/openvpn/server
if [ -z $1 ] || [ ! -f $1.conf ]; then
    for f in *.conf; do
        printf '%s\n' "${f%.conf}"
    done
else
    sudo iptables-restore </etc/iptables4.vpn
    echo "vpn" | sudo tee /iptables.txt

    sudo ln -sf /etc/openvpn/server/$1.conf /etc/openvpn/client.conf
    sudo systemctl enable openvpn@client.service
    sudo systemctl restart openvpn@client.service
fi
