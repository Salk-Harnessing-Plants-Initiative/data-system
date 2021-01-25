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

# How to query the images
The whole point of storing these images is for some future computational experiments in the lab whereby we are applying computer vision techniques on the top-down foliage images of greenhouse plants. You'll probably have to explain to the person doing these experiments how to query the images (or query for them):

```
SELECT * FROM image
WHERE experiment_id = 'yourexperiment-id-here', section_name = 'the-section-name-here', date(file_created) = yourdatehere
ORDER BY file_created ASC;
```

This query allows you to get the images for a particular experiment, a particular section (like a crop field or part of a greenhouse), and a particular date.

Then what you're gonna have to do is use the AWS S3 keys provided by `raw` column and download from there.  

Depending on how the plants were imaged and what the study is about, you might even have to stitch the photos together to get one big, continuous image of a particular section that you're examining. If this is the case, then the fact that we have done `ORDER BY file_created ASC` means that if the person who did the imaging with the Giraffe chronologically imaged the section from left to right, then you get the correct order of the photos for stitching. 

Hopefully some of these notes are helpful :)