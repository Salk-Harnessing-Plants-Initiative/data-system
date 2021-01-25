#!/bin/bash
docker build -t process-greenhouse-giraffe .
docker tag process-greenhouse-giraffe:latest 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-greenhouse-giraffe
aws ecr get-login-password | docker login --username AWS --password-stdin 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-greenhouse-giraffe
docker push 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-greenhouse-giraffe:latest
