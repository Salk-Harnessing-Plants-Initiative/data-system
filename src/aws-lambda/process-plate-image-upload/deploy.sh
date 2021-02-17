#!/bin/bash -e
docker build -t process-plate-image-upload .
docker tag process-plate-image-upload:latest 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-plate-image-upload
aws ecr get-login-password | docker login --username AWS --password-stdin 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-plate-image-upload
docker push 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-plate-image-upload:latest
