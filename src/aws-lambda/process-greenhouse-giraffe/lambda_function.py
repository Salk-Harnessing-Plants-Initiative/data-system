import os
import json
import psycopg2
import boto3

with open('config.json') as f:
    config = json.load(f)

s3_client = boto3.client('s3')
pg_cursor = psycopg2.connect(
    user=os.environ['user'],
    password=os.environ['password'],
    host=os.environ['host'],
    port=os.environ['port'],
    database=os.environ['database']).cursor()

def lambda_handler(event, context):
    for record in event['Records']:
        try:
            bucket = record['s3']['bucket']['name']
            image_key = record['s3']['object']['key']
            process(bucket, image_key)
        except Exception as e:
            print("Error: ", repr(e))

def process(bucket, image_key):
    global config
    global box_client
    global s3_client
    global pg_cursor
    if not image_key_valid(image_key):
        raise Exception("Image key '{}' invalid for filter".format(image_key))
    
    metadata = s3_client.head_object(Bucket=bucket, Key=image_key)['Metadata']
    file_created = metadata['file_created']
    user_input_filename = metadata['user_input_filename']
    qr_code = metadata['qr_code']
    giraffe_id = metadata['giraffe_id']

def image_key_valid(image_key, config):
    """Safety filter to ensure we are only processing files from 
    the correct directory in the bucket
    """
    return (os.path.dirname(image_key) == config['s3']['src_dir'])

