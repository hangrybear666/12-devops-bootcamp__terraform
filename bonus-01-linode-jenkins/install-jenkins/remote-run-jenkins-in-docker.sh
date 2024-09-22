#!/bin/bash

# extract the current directory name from pwd command (everything behind the last backslash
CURRENT_DIR=$(pwd | sed 's:.*/::')
if [ "$CURRENT_DIR" != "install-jenkins" ]
then
  echo "please change directory to install-jenkins folder and execute the shell script again."
  exit 1
fi

# load key value pairs from config file
source remote.properties
source ../.env

# setup file system for deployment
ssh $SERVICE_USER@$REMOTE_ADDRESS <<EOF
cd ~
if [ ! -d "jenkins" ]
then
  mkdir jenkins
  echo "jenkins directory created."
fi
EOF

# copy jenkins Docker image
echo "Copying files via scp..."
scp Dockerfile $SERVICE_USER@$REMOTE_ADDRESS:~/jenkins/

# ssh into remote with docker-user to download and run the jenkins image
ssh $SERVICE_USER@$REMOTE_ADDRESS <<EOF
# set sudo credentials for subsequent commands
echo $SERVICE_USER_PW | sudo -S ls

sudo docker network create jenkins

# run docker in docker container in which we will start jenkins, to have access to docker from the jenkins container
sudo docker run \
  --name jenkins-docker \
  --rm \
  --detach \
  --privileged \
  --network jenkins \
  --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind \
  --storage-driver overlay2

cd jenkins
sudo docker build -t jenkins-dind:2.462.1 .

sudo docker run \
  --name jenkins-dind \
  --restart=on-failure \
  --detach \
  --network jenkins \
  --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client \
  --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 \
  --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  jenkins-dind:2.462.1

EOF
