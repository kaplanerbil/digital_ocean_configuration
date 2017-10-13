#!/bin/bash
#set -e
#set -o xtrace  #print command which before execution

my_dir="$(dirname "$0")"

. $my_dir/droplet_set_variables.sh
echo DIGOCEAN_ID=$DIGOCEAN_ID

IP_ADDRESS=`curl -sXGET -u $DIGOCEAN_TOKEN:$DIGOCEAN_PASS "$DIGOCEAN_BASE_URL/droplets" | jq ".droplets[1].networks.v4[0].ip_address" | tr -d '"' `
export IP_ADRESS
 
echo IP_ADDRESS=$IP_ADDRESS
#sleep 3

if [ "null" = $IP_ADDRESS ]; then
	echo "no any droplet! you must create droplet before doing configuration." >> $my_dir/file.txt
#	exit 1
else


echo "IP_ADDRESS=$IP_ADDRESS" >> $my_dir/file.txt

fi


