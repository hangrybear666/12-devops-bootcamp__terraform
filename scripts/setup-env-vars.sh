#!/bin/bash

# extract the current directory name from pwd command (everything behind the last backslash
CURRENT_DIR=$(pwd | sed 's:.*/::')
if [ "$CURRENT_DIR" != "scripts" ]
then
  echo "please change directory to scripts folder and execute the shell script again."
  exit 1
fi

read -p "Please provide your AWS_ACCESS_KEY_ID: " ACCESS_KEY
read -p "Please provide your AWS_SECRET_ACCESS_KEY: " SECRET_KEY
read -p "Please provide your GIT_USER_NAME: " GIT_USER_NAME
read -p "Please provide your GIT_USER_EMAIL: " GIT_USER_EMAIL
read -p "Please provide your GIT_TOKEN: " GIT_TOKEN

AWS_REGION="eu-central-1"
AWS_OUTPUT_FORMAT="json"

cd ..
# create terraform .env file for ec2 project
touch terraform-01-ec2/.env
echo "# AWS CONFIG
AWS_ACCESS_KEY_ID=$ACCESS_KEY
AWS_SECRET_ACCESS_KEY=$SECRET_KEY
AWS_REGION=$AWS_REGION
# TF VARS
TF_VAR_EXAMPLE_VAR="example-env-var"
" > terraform-01-ec2/.env
echo "Created .env file with terraform secrets in" && echo "$(pwd)/terraform-01-ec2/" && echo "--------------------------------"

# copy terraform .env file for MODULARIZED ec2 project
cp terraform-01-ec2/.env terraform-02-ec2-modularized/.env
echo "Created .env file with terraform secrets in" && echo "$(pwd)/terraform-02-ec2-modularized/" && echo "--------------------------------"

# copy terraform .env file for AWS EKS project
cp terraform-01-ec2/.env terraform-03-aws-eks/.env
echo "Created .env file with terraform secrets in" && echo "$(pwd)/terraform-03-aws-eks/" && echo "--------------------------------"

# copy terraform .env file for CI CD Jenkins Integration
cp terraform-01-ec2/.env terraform-04-ci-cd-jenkins-provisioning/.env
echo "Created .env file with terraform secrets in" && echo "$(pwd)/terraform-04-ci-cd-jenkins-provisioning/" && echo "--------------------------------"
cat terraform-04-ci-cd-jenkins-provisioning/.env


#create ec2 .env file deployed on remote instance
touch terraform-01-ec2/payload/.env
echo "# GIT CONFIG
GIT_USER_NAME=$GIT_USER_NAME
GIT_USER_EMAIL=$GIT_USER_EMAIL
GIT_TOKEN=$GIT_TOKEN
# AWS CONFIG
AWS_ACCESS_KEY_ID=$ACCESS_KEY
AWS_ACCESS_KEY_SECRET=$SECRET_KEY
AWS_REGION=$AWS_REGION
AWS_OUTPUT_FORMAT=$AWS_OUTPUT_FORMAT
" > terraform-01-ec2/payload/.env
echo "Created .env file with ec2 secrets in" && echo "$(pwd)/terraform-01-ec2/payload/" && echo "--------------------------------"

#create ec2 .env file deployed on MODULARIZED remote instance
cp terraform-01-ec2/payload/.env terraform-02-ec2-modularized/payload/.env
echo "Created .env file with ec2 secrets in" && echo "$(pwd)/terraform-02-ec2-modularized/payload/" && echo "--------------------------------"
cat terraform-02-ec2-modularized/payload/.env