# TODO: Only timestamp from filename has been tested so far
# timestamp from exif and timestamp from metadata haven't 
import os
import json
import re
from io import StringIO, BytesIO
from datetime import datetime
import dateutil.parser
import traceback
import boto3
from pyzbar.pyzbar import decode
from PIL import Image
import psycopg2
from psycopg2 import Error
import pytz

def lambda_handler(event, context):
    for record in event['Records']:
        try:
            process(record)
        except Exception as e:
            traceback.print_exc()
            msg = "Error: " + repr(e)
            print(msg)
            return { 'statusCode': 400, 'Body' : msg}
    return { 'statusCode': 200 }

def process(record):
    bucket = record['s3']['bucket']['name']
    image_key = record['s3']['object']['key']

    # Safeguard against invalid triggers and infinite recursion
    if not image_key_valid(image_key):
        raise Exception("Invalid image key: {}".format(image_key))

    # Get relevant metadata about the image
    s3_client = boto3.client('s3')
    s3_resource = boto3.resource('s3')
    image = download_image(s3_client, bucket, image_key)
    container_id = decode_qr(image)
    timestamp = get_timestamp(s3_client, bucket, image_key, image)
    user_input_filename = get_user_input_filename(s3_client, bucket, image_key)
    upload_device_id = get_upload_device_id(s3_client, bucket, image_key)
    s3_upload_timestamp = get_s3_upload_timestamp(s3_resource, bucket, image_key)

    # Try to create a thumbnail copy of the image
    try:
        thumbnail_bytes = generate_thumbnail(image)
        thumbnail_key = create_thumbnail_key(image_key)
        upload_thumbnail(s3_client, bucket, thumbnail_key, thumbnail_bytes)
    except Exception as e:
        traceback.print_exc()
        msg = "Error: " + repr(e)
        print(msg)
        thumbnail_key = None

    # Record this image in our database
    insert_into_database(
        image_key=image_key, 
        container_id=container_id, 
        timestamp=timestamp,
        user_input_filename=user_input_filename, 
        thumbnail_key=thumbnail_key,
        upload_device_id=upload_device_id,
        s3_upload_timestamp=s3_upload_timestamp
    )

def image_key_valid(image_key):
    with open('config.json') as f:
        config = json.load(f)
        accepted_directory = (os.path.dirname(image_key) == config['directory']['src_dir'])
        return accepted_directory

def download_image(s3_client, bucket, image_key):
    s3_response_object = s3_client.get_object(Bucket=bucket, Key=image_key)
    object_content = s3_response_object['Body'].read()
    image = Image.open(BytesIO(object_content))
    return image

def decode_qr(image):
    try:
        # Capable of detecting multiple QRs in image, 
        # but we return arbitrary first QR detected
        qr_objects = decode(image)
        return qr_objects[0].data.decode()
    except:
        return None

# ========== GETTING TIMESTAMP ==========

def get_timestamp(s3_client, bucket, image_key, image):
    timestamp = get_timestamp_from_filename(image_key)
    if timestamp is None:
        timestamp = get_timestamp_from_exif(image)
    if timestamp is None:
        timestamp = get_timestamp_from_s3_metadata(s3_client, bucket, image_key)
    return timestamp

def get_timestamp_from_filename(image_key):
    # Parse timestamp out of file name (explicitly ONLY `YYYYMMDD-HHMMSS` as substring of filename)
    try:
        match = re.search(r'\d{8}-\d{6}', os.path.basename(image_key))
        timestamp = pytz.timezone('America/Los_Angeles').localize(datetime.strptime(match.group(), '%Y%m%d-%H%M%S'))
        return timestamp
    except:
        return None

def get_timestamp_from_exif(image):
    """ Parse timestamp out of EXIF metadata of .jpg and .tif files
    """
    # (https://www.awaresystems.be/imaging/tiff/tifftags/privateifd/exif.html)
    EXIF_TIMESTAMP_CODES = (36867, 36868)
    # Unwrap
    try:
        tags = image.tag # tiff
        tags = {k:v[0] for (k,v) in tags.items()}
    except:
        try:
            tags = image._getexif() # jpeg
        except:
            tags = {}
    # Try each tag type
    for code in EXIF_TIMESTAMP_CODES:
        try:
            return datetime.strptime(str(tags[code]), '%Y:%m:%d %H:%M:%S').astimezone()
        except:
            pass
    return None

def get_timestamp_from_s3_metadata(s3_client, bucket, image_key):
    try:
        response = s3_client.head_object(Bucket=bucket, Key=image_key)
        return dateutil.parser.parse(response['Metadata']['file_created'])
    except:
        return None

# ==============================

def get_s3_upload_timestamp(s3_resource, bucket, image_key):
    try:
        return s3_resource.Object(bucket, image_key).last_modified
    except Exception as e:
        print("Couldn't get s3_upload_timestamp: ", e)
        return None

def get_user_input_filename(s3_client, bucket, image_key):
    try:
        response = s3_client.head_object(Bucket=bucket, Key=image_key)
        return response['Metadata']['user_input_filename']
    except Exception as e:
        print("Couldn't get user_input_filename ", e)
        return None

def get_upload_device_id(s3_client, bucket, image_key):
    try:
        response = s3_client.head_object(Bucket=bucket, Key=image_key)
        return response['Metadata']['upload_device_id']
    except Exception as e:
        print("Couldn't get upload_device_id: ", e)
        return None

def generate_thumbnail(image, size=(1000, 1000)):
    buf = BytesIO()
    thumbnail = image.copy()
    thumbnail.thumbnail(size) # Makes into a thumbnail in-place
    thumbnail.save(buf, format='JPEG')
    thumbnail_bytes = buf.getvalue()
    return thumbnail_bytes

def create_thumbnail_key(image_key):
    # Change the extension to .jpg
    image_key = os.path.splitext(image_key)[0] + ".jpg"
    with open('config.json') as f:
        config = json.load(f)
        return os.path.join(config['directory']['dst_dir'], os.path.basename(image_key))

def upload_thumbnail(s3_client, bucket, thumbnail_key, thumbnail_bytes):
    s3_client.put_object(Body=thumbnail_bytes, Bucket=bucket, Key=thumbnail_key)

def insert_into_database(image_key, container_id=None, timestamp=None, user_input_filename=None, thumbnail_key=None,
    upload_device_id=None, s3_upload_timestamp=None):
    try:
        # Connect to an existing database
        connection = psycopg2.connect(user=os.environ['user'],
                                      password=os.environ['password'],
                                      host=os.environ['host'],
                                      port=os.environ['port'],
                                      database=os.environ['database'])
        connection.autocommit = True
        # Create a cursor to perform database operations
        cursor = connection.cursor()
        # Executing a SQL query
        query = (
            "INSERT INTO image (s3_key_raw, qr_code, image_timestamp, user_input_filename, s3_key_thumbnail, upload_device_id, s3_upload_timestamp)"
            "VALUES (%s, %s, %s, %s, %s, %s, %s);"
        )
        data = (image_key, container_id, timestamp, user_input_filename, thumbnail_key, upload_device_id, s3_upload_timestamp)
        cursor.execute(query, data)

    except (Exception, Error) as error:
        raise Exception("Error while connecting to PostgreSQL: ", error)
    finally:
        if (connection):
            cursor.close()
            connection.close()
