# Process image upload
* Intended to be triggered by S3 uploads to salk-hpi/images/raw or equivalent (* /raw)
* Attempts to decipher a QR code in the image as the container_id for the image
* Creates a 1000-pixel width jpg thumbnail at salk-hpi/images/thumbnail/1000px or equivalent (* /thumbail/1000px)
* If the raw image is less than 1000-pixels in width, then the original width is used instead

Currently supports .png, .jpg, .tif