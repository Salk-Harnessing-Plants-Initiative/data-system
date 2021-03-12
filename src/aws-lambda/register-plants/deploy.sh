#!/bin/bash -e
zip -r lambdaFunc.zip .
if [[ $1 == 'prod' ]]; then 
	aws lambda update-function-code --function-name register-plants --zip-file fileb:///Users/russelltran/Documents/code/salk-hpi/data-system/src/aws-lambda/register-plants/lambdaFunc.zip
else
	aws lambda update-function-code --function-name dev-register-plants --zip-file fileb:///Users/russelltran/Documents/code/salk-hpi/data-system/src/aws-lambda/register-plants/lambdaFunc.zip
fi