#!/bin/bash -e
GOOS=linux GOARCH=amd64 go build main.go
zip -r lambdaFunc.zip .
aws lambda update-function-code --function-name preflight-cylinder-image-upload --zip-file fileb:///Users/russelltran/Documents/code/salk-hpi/data-system/src/aws-lambda/preflight-cylinder-image-upload/lambdaFunc.zip