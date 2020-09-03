/usr/bin/tvservice -o

/home/pi/mac.sh wlan0 $(cat /mac_wlan.txt)
iptables-restore </etc/iptables.ipv4.nat

/home/pi/net_led.sh &
