# Box Greenhouse Giraffe
A backend service that reacts to the Greenhouse Giraffe Uploader. (Triggered by an S3 file upload). 
Makes copies of the image from S3 to the corresponding `box_image_folder_id`s that match the `qr_code` metadata field. 

You should know that `process-greenhouse-giraffe` is the other Lambda for recording the file record in the database.
The reason for all the Box business is because the greenhouse operations team uses Box as a user space, so they need a copy of their photos in the right places.  

# Configure
## Box 

1. `Create New App` > `Custom App` > `Server Authentication with JWT` > (go to app Configuration tab) > `Generate a Public/Private keypair` > `Download as JSON` > rename JSON to `box_config.json` and put in same directory as `main.py`
2. Enable this script to access your folders by sharing the relevant root folder with the email address of this "Service user". Find the email address by running the following:
```
pipenv run python get_email_address.py
```

# Deploy
Ensure `box_config.json` is in this directory.
```
sudo chmod 755 deploy.sh
./deploy.sh
```
"Deploy New Image" in the Lambda. (Also ensure environment variables for postgres are set if you haven't done so already).