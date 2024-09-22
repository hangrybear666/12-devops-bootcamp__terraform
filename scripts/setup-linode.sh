#!/bin/bash

# extract the current directory name from pwd command (everything behind the last backslash
CURRENT_DIR=$(pwd | sed 's:.*/::')
if [ "$CURRENT_DIR" != "scripts" ]
then
  echo "please change directory to scripts folder and execute the shell script again."
  exit 1
fi

read -p "Please provide your LINODE_API_TOKEN: " LINODE_API_TOKEN
read -p "Please provide your desired Linode root password: " ROOT_PWD

cd ..
# create terraform .env file for ec2 project
touch bonus-01-linode-jenkins/.env
echo "# LINODE CONFIG
LINODE_TOKEN="$LINODE_API_TOKEN"
# TF VARS
TF_VAR_root_password="$ROOT_PWD"
# JENKINS SERVER CONFIG
SERVICE_USER_PW=changeit
" > bonus-01-linode-jenkins/.env
echo "Created .env file with terraform secrets in" && echo "$(pwd)/bonus-01-linode-jenkins/" && echo "--------------------------------"
cat bonus-01-linode-jenkins/.env

export LINODE_TOKEN=$LINODE_API_TOKEN
export TF_VAR_root_password=$ROOT_PWD