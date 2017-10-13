#!/bin/bash
set -e
#set -o xtrace  #print command which before execution

my_dir="$(dirname "$0")"

. $my_dir/droplet_set_variables.sh

sudo apt-get install jq
sudo apt-get install curl

echo $1
if [ "$1" = "" ]; then
    echo "Plz choose one of region below! "
	echo "1 - New York 1"
    echo "2 - New York 2"
	echo "3 - New York 3"
    echo "4 - San Francisco 1"
    echo "5 - San Francisco 2"
    echo "6 - London 1"
    echo "7 - Singapore 1"
    echo "8 - Amsterdam 2"
    echo "9 - Amsterdam 3"
    echo "10 - Frankfurt 1"
    echo "11 - Toronto 1"
    echo "12 - Bangalore 1"

while true; do
read -p " region id:" regionId
    case $regionId in
        "1") REGION_NAME="New York 1"; break;;
        "2") REGION_NAME="New York 2"; break;;
		"3") REGION_NAME="New York 3"; break;;
		"4") REGION_NAME="San Francisco 1"; break;;
		"5") REGION_NAME="San Francisco 2"; break;;
		"6") REGION_NAME="London 1"; break;;
		"7") REGION_NAME="Singapore 1"; break;;
		"8") REGION_NAME="Amsterdam 2"; break;;
		"9") REGION_NAME="Amsterdam 3"; break;;
		"10") REGION_NAME="Frankfurt 1"; break;;
		"11") REGION_NAME="Toronto 1"; break;;
		"12") REGION_NAME="Bangalore 1"; break;;
        * ) echo "Please enter correct region id";;
    esac

done
fi

echo $REGION_NAME

SIZE_NAME="512"
DISTRIBUTION="Ubuntu"
OP_SYSTEM_NAME="cassandra1"

REGION_SLUG=`curl -sXGET -u $DIGOCEAN_TOKEN:$DIGOCEAN_PASS "$DIGOCEAN_BASE_URL/regions" | jq ".regions | map(select(.name==\"$REGION_NAME\"))[0].slug" `
echo "ID of Region $REGION_NAME is $REGION_SLUG"

SIZE_ID=`curl -sXGET -u $DIGOCEAN_TOKEN:$DIGOCEAN_PASS "$DIGOCEAN_BASE_URL/sizes" | jq ".sizes | map(select(.memory==$SIZE_NAME))[0].slug"`
echo "ID of Size $SIZE_NAME is $SIZE_ID"

IMAGE_ID=`curl -sXGET -u $DIGOCEAN_TOKEN:$DIGOCEAN_PASS "$DIGOCEAN_BASE_URL/images" | jq ".images | map(select(.distribution==\"$DISTRIBUTION\" and .name==\"$OP_SYSTEM_NAME\"))[0].id"`
echo "ID of Image $DISTRIBUTION is $IMAGE_ID"

SSH_KEY_ID=`curl -sXGET -u $DIGOCEAN_TOKEN:$DIGOCEAN_PASS "$DIGOCEAN_BASE_URL/account/keys" | jq ".ssh_keys | map(select(.name==\"$SSH_KEY_NAME\"))[0].id" `
echo "Activating SSH Key with ID $SSH_KEY_ID"

TIMESTAMP=`date '+%Y%m%d%H%M%S'`
DROPLET_NAME="droplet-$TIMESTAMP"

echo "Creating new Droplet $DROPLET_NAME with these specifications..."
RESULT=`curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $DIGOCEAN_TOKEN" -d '{"name":'"\"$DROPLET_NAME\""',"region":'"$REGION_SLUG"',"size":"512mb","image":"ubuntu-16-04-x64","ssh_keys":['"\"$SSH_KEY_ID"\"'],"backups":false,"ipv6":false,"user_data":null,"private_networking":null,"volumes": null,"tags":null}' "$DIGOCEAN_BASE_URL/droplets"`

STATUS=`echo $RESULT | jq '.droplet.status' | tr -d '"' `

echo "Status: $STATUS"
if [ "$STATUS" != "new" ]; then
    echo "Something went wrong:"
    echo $RESULT | jq .
#    exit 1
else
	DROPLET_ID=`echo $RESULT | jq '.droplet.id'`
	echo "Droplet with ID $DROPLET_ID created!"

	echo "Waiting for droplet to boot"
	for i in {1..60}; do
	    DROPLET_STATUS=`curl -sXGET -u $DIGOCEAN_TOKEN:$DIGOCEAN_PASS "$DIGOCEAN_BASE_URL/droplets" | jq ".droplets[0].status" | tr -d '"' `
	    [ "$DROPLET_STATUS" == 'active' ] && break
	    echo -n '.'
	    sleep 5
	done
	echo

	if [ "$DROPLET_STATUS" != 'active' ]; then
	    echo "Droplet did not boot in time. Status: $DROPLET_STATUS"
#	    exit 1
	else
		echo "*****************************"
		echo "* Droplet is ready to use!"
		echo "* IP address: $IP_ADDRESS"
		echo "*****************************"
	fi
fi

$SHELL
