#!/bin/bash -e
if [[ $1 == 'prod' ]]; then 
	docker build -t box-greenhouse-giraffe:prod .
	docker tag box-greenhouse-giraffe:prod 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-greenhouse-giraffe:prod
	aws ecr get-login-password | docker login --username AWS --password-stdin 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-greenhouse-giraffe
	docker push 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-greenhouse-giraffe:prod
	aws lambda update-function-code --function-name box-greenhouse-giraffe --image-uri 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-greenhouse-giraffe:prod
else
	docker build -t box-greenhouse-giraffe:dev .
	docker tag box-greenhouse-giraffe:dev 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-greenhouse-giraffe:dev
	aws ecr get-login-password | docker login --username AWS --password-stdin 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-greenhouse-giraffe
	docker push 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-greenhouse-giraffe:dev
	aws lambda update-function-code --function-name dev-box-greenhouse-giraffe --image-uri 295111184710.dkr.ecr.us-west-2.amazonaws.com/box-greenhouse-giraffe:dev
fi