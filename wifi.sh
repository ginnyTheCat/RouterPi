file=saved_wifis/$1.txt

ssid=$(sed -n '1p' $file)
password=$(sed -n '2p' $file)
mac=$(sed -n '3p' $file)

echo "ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=$(cat /country.txt)

network={
  ssid=\"$ssid\"
  psk=\"$password\"
}" | sudo tee /etc/wpa_supplicant/wpa_supplicant-wlan0.conf

echo $mac | sudo tee /mac_wlan.txt
./mac.sh wlan0 $mac
