import os
import json
from pyzbar.pyzbar import decode
from PIL import Image
from io import StringIO

def lambda_handler(event, context):
    for record in event['Records']:
        try:
            process(record)
        except:
            pass

def process(record):
    bucket = record['s3']['bucket']['name']
    image_key = record['s3']['object']['key']
    if not image_key_valid(image_key):
        return
    image = download_image(event)
    container_id = decode_qr(image)
    timestamp = get_timestamp(image_key, image)
    user_input_filename = get_user_input_filename(image_key)
    thumbnail = generate_thumbnail(image)
    thumbnail_key = create_thumbnail_key(image_key)
    upload_thumbnail(bucket, thumbnail_key, thumbnail)
    insert_into_database(image_key=image_key, container_id=container_id, timestamp=timestamp,
        user_input_filename=user_input_filename, thumbnail_key=thumbnail_key)

def image_key_valid(image_key):
    with open('config.json') as f:
        config = json.load(f)
        return accepted_directory(config, image_key) and accepted_filetype(config, image_key)

def accepted_directory(image_key):


# user_input_filename should come from s3 metadata

    # TODO implement
    print(decode(Image.open("taco.png")))
    print(decode(Image.open("russell_bacon_0.tif")))
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }


import psycopg2
from psycopg2 import Error

try:
    # Connect to an existing database
    connection = psycopg2.connect(user=os.environ['user'],
                                  password=os.environ['password'],
                                  host=os.environ['host'],
                                  port=os.environ['port'],
                                  database=os.environ['database'])

    # Create a cursor to perform database operations
    cursor = connection.cursor()
    # Print PostgreSQL details
    print("PostgreSQL server information")
    print(connection.get_dsn_parameters(), "\n")
    # Executing a SQL query
    cursor.execute("SELECT version();")
    # Fetch result
    record = cursor.fetchone()
    print("You are connected to - ", record, "\n")

except (Exception, Error) as error:
    print("Error while connecting to PostgreSQL", error)
finally:
    if (connection):
        cursor.close()
        connection.close()
        print("PostgreSQL connection is closed")