echo -n "WiFi: "
read name
file=saved_wifis/$name.txt

ssid=$(sed -n '1p' $file)
password=$(sed -n '2p' $file)

mac=$(sed -n '3p' $file)
if [ -z $mac ]; then
  mac=$(openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/:$//')
fi

echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=$(cat /country.txt)

network={
  ssid=\"$ssid\"
  psk=\"$password\"
}" | sudo tee /etc/wpa_supplicant/wpa_supplicant-wlan0.conf

echo $mac | sudo tee /mac.txt
./mac wlan0 $mac
