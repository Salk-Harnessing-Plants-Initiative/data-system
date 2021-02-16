# flatfile-csv
REST API for Flatfile.io CSV uploader data validation and data submission

* The API endpoint in AWS API Gateway is marked as open (open to the world) because some Flatfile webhooks can only be given a URL to call. So we have a custom inline parameter for a single api key called `apikey` that is stored as an environment variable. And we handle the API key ourself. Example,
```
https://p17ngindkb.execute-api.us-west-2.amazonaws.com/prod/flatfile-csv?apikey=taco
```
where `taco` is the apikey.