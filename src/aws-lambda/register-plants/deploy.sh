#!/bin/bash
zip -r lambdaFunc.zip .
aws lambda update-function-code --function-name register-plants --zip-file fileb:///Users/russelltran/Documents/code/salk-hpi/data-system/src/aws-lambda/register-plants/lambdaFunc.zip