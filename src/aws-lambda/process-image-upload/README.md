# Process image upload
* Intended to be triggered by S3 uploads to salk-hpi/images/raw or equivalent (* /raw)
* Attempts to decipher a QR code in the image as the `container_id` for the image
	* If QR can't be found, checks the UserComment field of the image EXIF
* Attempts to get a timestamp for the image using these attempts, listed in priority:
	* Parse timestamp out of file name (explicitly ONLY `YYYYMMDD-HHMMSS` as substring of filename). Assumes local time.
	* Parse timestamp out of EXIF metadata of .jpg and .tif files. Assumes local time.
	* Parse timestamp out of S3 metadata that we put there using one of our custom uploader clients
	(`file_created`)
* Attempts to get original user input filename from S3 metadata field we put there using one of our custom uploader clients (`user_input_filename`)
* Creates a max 1000x1000 resolution jpg thumbnail at salk-hpi/images/thumbnail/1000px or equivalent (* /thumbnail/1000px). Note, exif data is not copied over
	* If the raw image is less than 1000-pixels both in width and height, then the original resolution is used. Otherwise, resizing occurs and preserves aspect ratio, of course.
* Inserts all the information into a new row in the database

Supports .png, .jpg, .jpeg, .tif, .tiff for sure, and hypothetically should support any filetype supported by the pyton `PIL` module, which you can see as the list displayed from running `python -m PIL`. 

# Deployment
Deployment is a bit hairy for this Lambda.

1. Export Pipfile to overwrite requirements.txt
2. Create a Docker image
3. Update the Docker image on AWS