#!/bin/bash -e
if [[ $1 == 'prod' ]]; then 
	docker build -t box-update-greenhouse-csv:prod .
	docker tag box-update-greenhouse-csv:prod 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-update-greenhouse-csv:prod
	aws ecr get-login-password | docker login --username AWS --password-stdin 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-update-greenhouse-csv
	docker push 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-update-greenhouse-csv:prod
	aws lambda update-function-code --function-name box-update-greenhouse-csv --image-uri 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-update-greenhouse-csv:prod
else
	docker build -t box-update-greenhouse-csv:dev .
	docker tag box-update-greenhouse-csv:dev 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-update-greenhouse-csv:dev
	aws ecr get-login-password | docker login --username AWS --password-stdin 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-update-greenhouse-csv
	docker push 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-update-greenhouse-csv:dev
	aws lambda update-function-code --function-name dev-box-update-greenhouse-csv --image-uri 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-update-greenhouse-csv:dev
fi