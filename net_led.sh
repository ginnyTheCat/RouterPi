cd /sys/class/leds/led0
echo none >trigger

while true; do
    if ping -qc1 -W 1 google.com >/dev/null 2>&1; then
        echo 1 >brightness
    else
        echo 0 >brightness
    fi
    sleep 3
done
