# Register plants
Randomly generates new nanoids for containers and plants.
Registers said nanoids, creates CSVs for the user to create QR codes
and associate data with their plant. Returns the S3 keys for the
CSVs.

Usage: event should have the following:
```
{
    experiment_id : string
    container_type : string (e.g. should be "plate", "cylinder", "pot")
    num_containers : can be a number or a number as a string
    plants_per_container : can be a number or a number as a string
    created_by : the user id (optional)
}
```

# Deployment
```
npm install
```
Zip and deploy:
```
zip -r lambdaFunc.zip .
aws lambda update-function-code --function-name register-plants --zip-file \absolute\path\to\the\zip\file
```

# Nanoid
We use nanoid instead of the usual uuid v4. This is to keep the QR codes smaller.

The `plant_id`s are 21-char, which is the default for nanoid and theoretical equivalent to uuids. The `container_id`s are 14-char, and that's because we are trying to optimize within the constraints of printing QR codes on tiny labels, and also the finicky behavior of the BradyID Workstation software (barcode printer label design software). The smallest QR Brady can generate can hold up to 7 chars, and then the capacity for the next QR size is 14. We'll get a smaller (safer) QR code with 14 instead of 21. 

If you're curious, 14 is still within theoretical safety: https://zelark.github.io/nano-id-cc/