#!/bin/bash

#Prerequisites setup
sudo apt-get update &&
sudo apt-get install -yqq \
	curl \
	git \
	apt-transport-https \
	ca-certificates \
	gnupg \
	gnupg-agent \
	software-properties-common

sudo install -m 0755 -d /etc/apt/keyrings
curl-fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null &&
sudo apt-get update && 
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -yqq &&
sudo chmod +x /usr/local/bin/docker-compose &&
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

#Configuring server parameters with user input

#Desired number of peers
read -p 'Number of peers: ' peers
sed -i "s/SET_NUMBER_OF_PEERS/$peers/g" .env

#WGUI session secret, should be secure
read -sp 'Wireguard UI session secret, not the password, put in a secure value: ' WGUISS
sed -i "s/SET_SESSION_SECRET/$WGUISS/g" .env

#WGUI password
read -sp 'Wireguard UI password: ' WGUIpass
sed -i "s/SET_PASSWORD_WGUI/$WGUIpass/g" .env

#Pi-hole password
read -sp 'Pi-hole password: ' PHpass
sed -i "s/SET_PASSWORD_PIHOLE/$PHpass/g" .env

# Replace the public IP placeholder in the docker-compose.yml
sed -i "s/REPLACE_ME_WITH_YOUR_PUBLIC_IP/$(curl -s ifconfig.me)/g" docker-compose.yml

docker compose up
