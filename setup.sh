COUNTRY=DE

INTERNAL_WLAN=aa:bb:cc:dd:ee:ff
EXTERNAL_WLAN=aa:bb:cc:dd:ee:ee
RANGE_WLAN=1

# 2.4 GHz
MODE=g
CHANNEL=7

# 5 GHz
# MODE=a
# CHANNEL=36

INTERNAL_ETH=11:22:33:44:55:66
EXTERNAL_ETH=11:22:33:44:66:66
RANGE_ETH=2

DHCP_LEASING_TIME=24h

# Install packets
sudo apt-get update
sudo apt-get install -y dnsmasq hostapd openvpn

orig_file() {
    if [ ! -f $1.orig ]; then
        sudo cp $1 $1.orig
    fi
    sudo cp $1.orig $1
}

echo $COUNTRY | sudo tee /country.txt

# Fix interfaces
echo "SUBSYSTEM==\"net\", ACTION==\"add\", DRIVERS==\"?*\", ATTR{address}==\"$EXTERNAL_WLAN\", ATTR{type}==\"1\", NAME=\"wlan0\"
SUBSYSTEM==\"net\", ACTION==\"add\", DRIVERS==\"?*\", ATTR{address}==\"$INTERNAL_WLAN\", ATTR{type}==\"1\", NAME=\"wlan1\"
SUBSYSTEM==\"net\", ACTION==\"add\", DRIVERS==\"?*\", ATTR{address}==\"$EXTERNAL_ETH\", ATTR{type}==\"1\", NAME=\"eth0\"
SUBSYSTEM==\"net\", ACTION==\"add\", DRIVERS==\"?*\", ATTR{address}==\"$INTERNAL_ETH\", ATTR{type}==\"1\", NAME=\"eth1\"" | sudo tee /etc/udev/rules.d/70-persistent-net.rules

# Set IP static
orig_file /etc/dhcpcd.conf
echo "interface wlan1
static ip_address=192.168.$RANGE_WLAN.1/24
interface eth1
static ip_address=192.168.$RANGE_ETH.1/24" | sudo tee -a /etc/dhcpcd.conf

# Create DHCP config
echo "dhcp-range=wlan1,192.168.$RANGE_WLAN.2,192.168.$RANGE_WLAN.255,$DHCP_LEASING_TIME
dhcp-range=eth1,192.168.$RANGE_ETH.2,192.168.$RANGE_ETH.255,$DHCP_LEASING_TIME" | sudo tee /etc/dnsmasq.conf

# Get WiFi settings
echo -n "SSID: "
read SSID
echo -n "Password: "
read PASSWORD

# Create WiFi config
echo "interface=wlan1
ssid=$SSID
channel=$CHANNEL
hw_mode=$MODE
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
chmod +x boot.sh ip.sh leases.sh mac.sh net_led.sh rtl8192eu.sh wifi.sh vpn/disable.sh vpn/enable.sh vpn/gen_protonvpn.sh

# Config iptables
orig_file /etc/sysctl.conf
echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf

if [ ! -f /etc/iptables4.normal ]; then
    echo "normal" | sudo tee /iptables.txt

    sudo iptables -t nat -A POSTROUTING -o tun0 -j MASQUERADE
    sudo iptables-save | sudo tee /etc/iptables4.vpn

    sudo iptables -t nat -F
    sudo iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
    sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    sudo iptables-save | sudo tee /etc/iptables4.normal
fi

# Autostart tools
sudo mv boot.sh /boot.sh
orig_file /etc/rc.local
sudo sed -i '/^exit 0/i /boot.sh' /etc/rc.local

echo "router" | sudo tee /etc/hostname
passwd

sudo mv /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant-wlan0.conf
