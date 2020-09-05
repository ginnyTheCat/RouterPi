mac=$(sed -n '1p' $file)

echo $mac | sudo tee /mac_lan.txt
./mac.sh lan0 $mac
