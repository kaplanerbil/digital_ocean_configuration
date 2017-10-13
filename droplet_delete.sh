#!/bin/bash
set -e
#set -o xtrace  #print command which before execution

my_dir="$(dirname "$0")"

echo $my_dir

. $my_dir/droplet_set_variables.sh

DROPLET_ID=`curl -sXGET -u $DIGOCEAN_TOKEN:$DIGOCEAN_PASS "$DIGOCEAN_BASE_URL/droplets" | jq ".droplets[1].id" `

if [ "null" = $DROPLET_ID ]; then
	echo "no any droplet!"
#	exit 1
else

echo DROPLET_ID=$DROPLET_ID

RESULT=`curl -X DELETE -i -H "Content-Type: application/json" -H "Authorization: Bearer $DIGOCEAN_TOKEN" "$DIGOCEAN_BASE_URL/droplets/$DROPLET_ID" `

echo RESULT=$RESULT

STATUS=`echo $RESULT | jq -r '.status'`

echo "Status: $STATUS"
if [ "$STATUS" != "OK" ]; then
    echo "Something went wrong:"
    echo $RESULT | jq .
#    exit 1
fi

fi

$SHELL
