#!/bin/bash
docker build -t box-update-greenhouse-csv .
docker tag box-update-greenhouse-csv:latest 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-update-greenhouse-csv  
aws ecr get-login-password | docker login --username AWS --password-stdin 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-update-greenhouse-csv
docker push 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-update-greenhouse-csv:latest
