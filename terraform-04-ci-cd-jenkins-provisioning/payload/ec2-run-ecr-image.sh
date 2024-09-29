#!/bin/bash

aws configure set aws_access_key_id $1
aws configure set aws_secret_access_key $2
aws configure set region eu-central-1
aws ecr get-login-password --region eu-central-1 | docker login --username AWS --password-stdin $3
docker run -d -p 8080:8080 $4