# Deployment
```
npm install
```
Zip and deploy:
```
zip -r lambdaFunc.zip .
aws lambda update-function-code --function-name process-data-commit --zip-file \absolute\path\to\the\zip\file
```