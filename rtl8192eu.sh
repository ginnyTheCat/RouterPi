apt-get install -y git raspberrypi-kernel-headers build-essential dkms
git clone https://github.com/Mange/rtl8192eu-linux-driver
cd rtl8192eu-linux-driver

sed -i 's/CONFIG_PLATFORM_I386_PC = y/CONFIG_PLATFORM_I386_PC = n/' Makefile
sed -i 's/CONFIG_PLATFORM_ARM_RPI = n/CONFIG_PLATFORM_ARM_RPI = y/' Makefile

dkms add .
dkms install rtl8192eu/1.0

echo "blacklist rtl8xxxu" >/etc/modprobe.d/rtl8xxxu.conf
echo -e "8192eu\n\nloop" >/etc/modules
# echo "options 8192eu rtw_power_mgnt=0 rtw_enusbss=0" > /etc/modprobe.d/8192eu.conf
