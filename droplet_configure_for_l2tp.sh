#!/bin/bash
#set -e
#set -o xtrace  #print command which before execution

my_dir="$(dirname "$0")"

. $my_dir/droplet_set_variables.sh
echo DIGOCEAN_ID=$DIGOCEAN_ID

echo VPNsunucusu kurulumu baslatiliyor
IP_ADDRESS=`curl -sXGET -u $DIGOCEAN_TOKEN:$DIGOCEAN_PASS "$DIGOCEAN_BASE_URL/droplets" | jq ".droplets[1].networks.v4[0].ip_address" | tr -d '"' `
export IP_ADRESS
 
echo IP_ADDRESS=$IP_ADDRESS
#sleep 3

if [ "null" = $IP_ADDRESS ]; then
	echo "no any droplet! you must create droplet before doing configuration."
#	exit 1
else

#ssh-keygen -R $IP_ADDRESS
SSH_OPTIONS="-o StrictHostKeyChecking=no"
export SSH_OPTIONS

ssh $SSH_OPTIONS root@$IP_ADDRESS '
set -o xtrace
apt-get update && apt-get upgrade -y
apt-get install build-essential -y
curl -o softether.tar.gz http://www.softether-download.com/files/softether/v4.20-9608-rtm-2016.04.17-tree/Linux/SoftEther_VPN_Server/64bit_-_Intel_x64_or_AMD64/softether-vpnserver-v4.20-9608-rtm-2016.04.17-linux-x64-64bit.tar.gz
tar xzvf softether.tar.gz
cd vpnserver
yes '1' | make  


cd ..
mv vpnserver /usr/local
cd /usr/local/vpnserver/
chmod 600 *
chmod 700 vpnserver
chmod 700 vpncmd
cd /etc/init.d/
wget http://pastebin.com/raw.php?i=9EBH7UMH -O vpnserver
apt-get install dos2unix
dos2unix vpnserver
mkdir /var/lock/subsys
chmod 755 /etc/init.d/vpnserver && /etc/init.d/vpnserver start
update-rc.d vpnserver defaults

cd /usr/local/vpnserver/
cat>droplet_config.sh<<EOF
#!/usr/bin/expect
set -o xtrace

spawn ./vpncmd
expect "Select 1, 2 or 3:"
send "1\r"
expect "Hostname of IP Address of Destination:"
send "\r"
expect "Specify Virtual Hub Name:"
send "\r"
expect "VPN Server>"
send "ServerPasswordSet\r"
expect "Password:"
send "admin123\r"
expect "Confirm input:"
send "admin123\r"
expect "VPN Server>"
send "HubCreate VPN\r"
expect "Password:"
send "xx160119\r"
expect "Confirm input:"
send "xx160119\r"
expect "VPN Server>"
send "Hub VPN\r"
expect "VPN Server/VPN>"
send "SecureNatEnable\r"
expect "VPN Server/VPN>"
send "UserCreate test\r\r\r\r"
expect "VPN Server/VPN>"
send "UserPasswordSet test\r"
expect "Password:"
send "1601yy\r"
expect "Confirm input:"
send "1601yy\r"
expect "VPN Server/VPN>"
send "IPsecEnable\r"
expect "Enable L2TP over IPsec Server Function (yes / no):"
send "yes\r"
expect "Enable Raw L2TP Server Function (yes / no):"
send "no\r"
expect "Enable EtherIP / L2TPv3 over IPsec Server Function (yes / no):"
send "no\r"
expect "Pre Shared Key for IPsec (Recommended: 9 letters at maximum):"
send "vpn\r"
expect "Default Virtual HUB in a case of omitting the HUB on the Username:"
send "VPN\r"
expect "VPN Server/VPN>"
send "exit"
EOF

yes 'Y' |apt-get install expect
chmod 755 ./droplet_config.sh
./droplet_config.sh

'
echo "IP_ADDRESS=$IP_ADDRESS"
fi
$SHELL
