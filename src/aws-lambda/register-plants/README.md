# Deployment
```
npm install
```
Zip and deploy:
```
zip -r lambdaFunc.zip .
aws lambda update-function-code --function-name register-plants --zip-file \absolute\path\to\the\zip\file
```