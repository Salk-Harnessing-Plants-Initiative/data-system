# Process Greenhouse Giraffe
A backend service that reacts to the Greenhouse Giraffe Uploader. (Triggered by an S3 file upload). 
Interprets the S3 metadata and records the image as a record in Postgres for future querying. 

You should know that `box-greenhouse-giraffe` is the other Lambda that is used for putting copies of the Giraffe images in the appropriate folders in Box. 

# Deploy
```
sudo chmod 755 deploy.sh
./deploy.sh
```
"Deploy New Image" in the Lambda. (Also ensure environment variables for postgres are set if you haven't done so already).