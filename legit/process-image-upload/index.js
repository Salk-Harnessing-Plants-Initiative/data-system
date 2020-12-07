/*
Salk Harnessing Plants Initiative
AWS Lambda for processing plant image uploads
Russell Tran
December 2020

Intended to be triggered by S3 uploads to salk-hpi/images/raw or equivalent (* /raw)
Attempts to decipher a QR code in the image as the container_id for the image
Creates a 1000-pixel width png thumbnail at salk-hpi/images/thumbnail/1000px (* /thumnbail/1000px)
If the raw image is less than 1000-pixels in width, then the original width is used instead

Currently supports .png, .jpg, .tif

https://docs.aws.amazon.com/lambda/latest/dg/with-s3-example.html
http://thecodebarbarian.com/creating-qr-codes-with-node-js.html
*/

// For AWS S3
const AWS = require('aws-sdk');
const bucket = process.env.bucket;
const s3 = new AWS.S3();
const node_path = require('path');
// For image resizing (thumbnails)
const sharp = require('sharp');
// For QR
const QRReader = require('qrcode-reader');
const jimp = require('jimp');
// For Postgres
const {v4 : uuidv4} = require('uuid');
const pg = require("pg");
const format = require('pg-format');
const pool = new pg.Pool({
    user: process.env.user,
    host: process.env.host,
    database: process.env.database,
    password: process.env.password,
    port: process.env.port
});
// Set thumbnail width
const width  = process.env.width;

exports.handler = async (event, context, callback) => {
    const srcBucket = event.Records[0].s3.bucket.name;
    // Object key may have spaces or unicode non-ASCII characters.
    // TODO: Consider necessity of this regex since it was copied from
    // https://docs.aws.amazon.com/lambda/latest/dg/with-s3-example.html
    const srcKey = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, " "));
    const user_input_filename = node_path.basename(srcKey);

    // Infer the image type from the file suffix.
    const typeMatch = srcKey.match(/\.([^.]*)$/);
    if (!typeMatch) {
        console.log("Could not determine the image type.");
        return;
    }
    // Check that the image type is supported  
    const imageType = typeMatch[1].toLowerCase();
    if (imageType != "jpg" && imageType != "png" && imageType != "tif") {
        console.log(`Unsupported image type: ${imageType}`);
        return;
    }
    // Download the image from the S3 source bucket. 
    try {
        const params = {
            Bucket: srcBucket,
            Key: srcKey
        };
        var origimage = await s3.getObject(params).promise();
    } catch (error) {
        console.log(error);
        return;
    }  

    // Success values
    let success_qr = false;
    let success_thumbnail = false;

    // Attempt to read the QR code
    let qr_value;
    try {
    	let buffer = await sharp(origimage.Body).toBuffer();
        const img = await jimp.read(buffer);
        const qr = new QRReader();
        // qrcode-reader's API doesn't support promises, so wrap it
        const value = await new Promise((resolve, reject) => {
            qr.callback = (err, v) => err != null ? reject(err) : resolve(v);
            qr.decode(img.bitmap);
        });
        qr_value = value.result;
    } catch (error) {
        console.log(error);
    }

    // Use the Sharp module to resize the image and save in a buffer.
    // Resize will set the height automatically to maintain aspect ratio.
    try { 
        let thumbnail_buffer = await sharp(origimage.Body).resize(width).toBuffer();
    } catch (error) {
        console.log(error);
    } 
    // Upload the thumbnail image to the destination bucket
    const dstBucket = srcBucket;
    const dstKey = `thumbnail/${width.toString()}px/${user_input_filename}`;
    try {
        const destparams = {
            Bucket: dstBucket,
            Key: dstKey,
            Body: thumbnail_buffer,
            ContentType: "image"
        };
        const putResult = await s3.putObject(destparams).promise(); 

    } catch (error) {
        console.log(error);
    } 

    // Insert into table
    // TODO: Ternary operators totally required here if you want to proceed even if a step fails
    try {
    	await pool.query(`INSERT INTO image (raw, thumbnail, container_id, user_input_filename) VALUES (${srcKey}, ${dstKey}, ${qr_value}, ${user_input_filename})`);
    } catch (error) {
    	console.log(error);
    	return;
    }
        
    console.log(`Done for ${srcBucket}/${srcKey}. Success QR = ${success_qr}, success thumbnail = ${success_thumbnail}`);

};

// TODO: What happens if multiple QR codes are detected?
// TODO: Should abort if any step fails?