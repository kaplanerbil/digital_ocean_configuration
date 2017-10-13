#!/bin/bash
set -e
#set -o xtrace  #print command which before execution

my_dir="$(dirname "$0")"
. $my_dir/droplet_set_variables.sh

echo DIGOCEAN_ID=$DIGOCEAN_ID

IP_ADDRESS=`curl -sXGET -u $DIGOCEAN_TOKEN:$DIGOCEAN_PASS "$DIGOCEAN_BASE_URL/droplets" | jq ".droplets[0].networks.v4[0].ip_address" | tr -d '"' `

#yeni
ssh root@$IP_ADDRESS "bash -s" < get_docker_com.sh 


#eski

: <<'komut'

if [ "null" = $IP_ADDRESS ]; then
	echo "no any droplet! you must create droplet before doing configuration."
	#	exit 1
else
ssh $SSH_OPTIONS root@$IP_ADDRESS `
echo "Execute bootstrap script"
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
sudo apt-get update
sudo apt-get install -y docker-engine
#curl -o "https://gist.github.com/christianberg/6082234/raw/bootstrap.sh"
#./bootstrap.sh
`
fi

komut

$SHELL
