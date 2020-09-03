COUNTRY=DE

INTERNAL_WLAN=wlan0
EXTERNAL_WLAN=wlan1
RANGE_WLAN=1
CHANNEL=7

INTERNAL_ETH=eth1
EXTERNAL_ETH=eth0
RANGE_ETH=2

# Install packets
sudo apt-get update
sudo apt-get install -y dnsmasq hostapd

orig_file() {
    if [ ! -f $1.orig ]; then
        sudo cp $1 $1.orig
    fi
    sudo cp $1.orig $1
}

# Set IP static
orig_file /etc/dhcpcd.conf
echo "interface $INTERNAL_WLAN
static ip_address=192.168.$RANGE_WLAN.1/24
interface $INTERNAL_ETH
static ip_address=192.168.$RANGE_ETH.1/24" | sudo tee -a /etc/dhcpcd.conf

# Create DHCP config
echo "dhcp-range=$INTERNAL_WLAN,192.168.$RANGE_WLAN.2,192.168.$RANGE_WLAN.255,255.255.255.0,24h
dhcp-range=$INTERNAL_ETH,192.168.$RANGE_ETH.2,192.168.$RANGE_ETH.255,255.255.255.0,24h" | sudo tee /etc/dnsmasq.conf

# Get WiFi settings
echo -n "SSID: "
read SSID
echo -n "Password: "
read PASSWORD

# Create WiFi config
echo "interface=$INTERNAL_WLAN
ssid=$SSID
channel=$CHANNEL
hw_mode=g
ieee80211n=1
ieee80211d=1
country_code=$COUNTRY
wmm_enabled=1
auth_algs=1
wpa=2
wpa_key_mgmt=WPA-PSK
rsn_pairwise=CCMP
wpa_passphrase=$PASSWORD" | sudo tee /etc/hostapd/hostapd.conf

sudo systemctl unmask hostapd
sudo systemctl enable hostapd

# Make tools executable
chmod +x leases.sh mac.sh net_led.sh rtl8192eu.sh

# Config iptables
orig_file /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

orig_file /etc/rc.local
sudo iptables -t nat -A POSTROUTING -o $EXTERNAL_WLAN -j MASQUERADE
sudo iptables -t nat -A POSTROUTING -o $EXTERNAL_ETH -j MASQUERADE

sudo iptables-save >/etc/iptables.ipv4.nat
sudo sed -i '/^exit 0/i iptables-restore < /etc/iptables.ipv4.nat
/home/pi/net_led.sh &' /etc/rc.local
