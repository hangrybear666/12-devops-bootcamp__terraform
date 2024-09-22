#!/bin/bash

# load key value pairs from config file
source remote.properties
source ../.env

read -p "Please provide public ssh key path: " PUB_KEY_PATH

# to properly read the tilde and interpret it as the correct HOME path we use eval
EXPANDED_PUB_KEY_PATH=$(eval echo $PUB_KEY_PATH)
PUBLIC_KEY=$(cat $EXPANDED_PUB_KEY_PATH)

ssh $ROOT_USER@$REMOTE_ADDRESS <<EOF
# reset prior user and the respective home folder
userdel -r $SERVICE_USER

#create new user
useradd -m $SERVICE_USER

# add sudo privileges to service user
sudo cat /etc/sudoers | grep $SERVICE_USER

if [ -z "\$( sudo cat /etc/sudoers | grep $SERVICE_USER )" ]
then
  echo "$SERVICE_USER ALL=(ALL:ALL) ALL" | sudo EDITOR="tee -a" visudo
  echo "$SERVICE_USER added to sudoers file."
else
  echo "$SERVICE_USER found in sudoers file."
fi

echo "$SERVICE_USER:$SERVICE_USER_PW" | chpasswd

# switch to new user
su - $SERVICE_USER

# add public key to new user's authorized keys
mkdir .ssh
cd .ssh
touch authorized_keys
echo "created .ssh/authorized keys file"
echo "$PUBLIC_KEY" > authorized_keys
echo "added public key to authorized_keys file of new user."

# change default shell to bash
sudo usermod --shell /bin/bash \$USER
EOF

# ssh into remote with newly created user to download Docker Engine
ssh $SERVICE_USER@$REMOTE_ADDRESS <<EOF

# set sudo credentials for subsequent commands
echo $SERVICE_USER_PW | sudo -S ls

# remove prior docker installations
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo -S apt-get remove \$pkg; done

# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get -y install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  \$(. /etc/os-release && echo "\$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# install docker
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo "Installed docker version: \$(docker -v)"
echo "Installed docker compose version: \$(docker compose version)"

#Start docker daemon service
sudo systemctl start docker

# add user to docker group so docker commands can be run without sudo
sudo usermod -aG docker \$USER

# immediately activate group assignment
newgrp docker
EOF
