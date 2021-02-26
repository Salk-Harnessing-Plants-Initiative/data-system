#!/bin/bash -e
if [[ $1 == 'prod' ]]; then 
	docker build -t process-plate-image-upload:prod .
	docker tag process-plate-image-upload:prod 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-plate-image-upload:prod
	aws ecr get-login-password | docker login --username AWS --password-stdin 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-plate-image-upload
	docker push 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-plate-image-upload:prod
	aws lambda update-function-code --function-name process-plate-image-upload --image-uri 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-plate-image-upload:prod
else
	docker build -t process-plate-image-upload:dev .
	docker tag process-plate-image-upload:dev 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-plate-image-upload:dev
	aws ecr get-login-password | docker login --username AWS --password-stdin 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-plate-image-upload
	docker push 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-plate-image-upload:dev
	aws lambda update-function-code --function-name dev-process-plate-image-upload --image-uri 295111184710.dkr.ecr.us-west-2.amazonaws.com/process-plate-image-upload:dev
fi