/usr/bin/tvservice -o

/home/pi/mac.sh wlan0 $(cat /mac_wlan.txt)
iptables-restore </etc/iptables4.$(cat /iptables.txt)

/home/pi/net_led.sh &
