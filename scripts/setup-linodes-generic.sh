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
#  create linode .env file  for 2nd bonus project
touch bonus-02-linodes-generic/.env
echo "# LINODE CONFIG
LINODE_TOKEN="$LINODE_API_TOKEN"
# TF VARS
TF_VAR_root_password="$ROOT_PWD"
" > bonus-02-linodes-generic/.env
echo "Created .env file with terraform secrets in" && echo "$(pwd)/bonus-02-linodes-generic/" && echo "--------------------------------"
cat bonus-02-linodes-generic/.env

touch bonus-03-s3-state-backend/.env
echo "# LINODE CONFIG
LINODE_TOKEN="$LINODE_API_TOKEN"
" > bonus-03-s3-state-backend/.env
echo "Created .env file with terraform secrets in" && echo "$(pwd)/bonus-03-s3-state-backend/" && echo "--------------------------------"
cat bonus-03-s3-state-backend/.env

export LINODE_TOKEN=$LINODE_API_TOKEN
export TF_VAR_root_password=$ROOT_PWD