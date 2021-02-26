#!/bin/bash -e
if [[ $1 == 'prod' ]]; then 
	docker build -t process-cylinder-image-upload:prod .
	docker tag process-cylinder-image-upload:prod 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-cylinder-image-upload:prod
	aws ecr get-login-password | docker login --username AWS --password-stdin 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-cylinder-image-upload
	docker push 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-cylinder-image-upload:prod
	aws lambda update-function-code --function-name process-cylinder-image-upload --image-uri 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-cylinder-image-upload:prod
else
	docker build -t process-cylinder-image-upload:dev .
	docker tag process-cylinder-image-upload:dev 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-cylinder-image-upload:dev
	aws ecr get-login-password | docker login --username AWS --password-stdin 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-cylinder-image-upload
	docker push 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-cylinder-image-upload:dev
	aws lambda update-function-code --function-name dev-process-cylinder-image-upload --image-uri 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-cylinder-image-upload:dev
fi