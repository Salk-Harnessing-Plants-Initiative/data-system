#!/bin/bash
docker build -t box-greenhouse-giraffe .
docker tag box-greenhouse-giraffe:latest 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-greenhouse-giraffe
aws ecr get-login-password | docker login --username AWS --password-stdin 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-greenhouse-giraffe
docker push 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-greenhouse-giraffe:latest
