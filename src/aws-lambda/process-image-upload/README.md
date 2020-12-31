# Why this code was put into the graveyard
The current Nodejs modules out there for decoding QR codes are weak and don't even work for our 131 MB .tif plate scans. Namely, `qrcode-reader` and `jsqr` had much poorer performance than `zbar`, a binary library that has been [benchmarked](https://boofcv.org/index.php?title=Performance:QrCode) as pretty robust and is exposed to a Python API but doesn't have a good Nodejs one yet. Also, `sharp`'s ability to parse exif metadata was flaky. 

# Deployment
You should note that the node module `sharp` is OS-platform dependent. Thus,
```
npm install --arch=x64 --platform=linux --target=12.13.0  sharp
```
is good to keep in mind if you run into trouble when trying to get this to work on AWS Lambda (which uses Linux).

Then just install the rest of the modules:
```
npm install
```
Zip and deploy:
```
zip -r lambdaFunc.zip .
aws lambda update-function-code --function-name the-function-name --zip-file \absolute\path\to\the\zip\file
```