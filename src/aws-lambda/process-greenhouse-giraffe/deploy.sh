#!/bin/bash -e
if [[ $1 == 'prod' ]]; then 
	docker build -t process-greenhouse-giraffe:prod .
	docker tag process-greenhouse-giraffe:prod 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-greenhouse-giraffe:prod
	aws ecr get-login-password | docker login --username AWS --password-stdin 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-greenhouse-giraffe
	docker push 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-greenhouse-giraffe:prod
	aws lambda update-function-code --function-name process-greenhouse-giraffe --image-uri 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-greenhouse-giraffe:prod
else
	docker build -t process-greenhouse-giraffe:dev .
	docker tag process-greenhouse-giraffe:dev 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-greenhouse-giraffe:dev
	aws ecr get-login-password | docker login --username AWS --password-stdin 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-greenhouse-giraffe
	docker push 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-greenhouse-giraffe:dev
	aws lambda update-function-code --function-name dev-process-greenhouse-giraffe --image-uri 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-greenhouse-giraffe:dev
fi