import os
import json
from datetime import datetime
import psycopg2
import boto3

with open('config.json') as f:
    config = json.load(f)

s3_client = boto3.client('s3')
s3_resource = boto3.resource('s3')
pg_cursor = psycopg2.connect(
    user=os.environ['user'],
    password=os.environ['password'],
    host=os.environ['host'],
    port=os.environ['port'],
    database=os.environ['database']).cursor()

def lambda_handler(event, context):
    # Parse the SNS event to get the S3 event inside
    sns_message = event['Records'][0]['Sns']['Message']
    s3_event = json.loads(sns_message)

    for record in s3_event['Records']:
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
    global s3_resource
    global pg_cursor
    if not image_key_valid(image_key, config):
        raise Exception("Image key '{}' invalid for filter".format(image_key))
    
    metadata = s3_client.head_object(Bucket=bucket, Key=image_key)['Metadata']
    s3_last_modified = s3.Object(bucket, image_key).last_modified
    insert_into_image_table(pg_cursor, image_key, metadata, s3_last_modified)
    results = query_matching_experiments(pg_cursor, qr_code)
    for result in results:
        experiment_id, section_name = result[0], result[1]
        insert_into_image_match_table(pg_cursor, image_key, experiment_id, section_name)

def image_key_valid(image_key, config):
    """Safety filter to ensure we are only processing files from 
    the correct directory in the bucket
    """
    return (os.path.dirname(image_key) == config['s3']['src_dir'])

def get(metadata, tag):
    if tag in metadata:
        return metadata[tag]
    else:
        return None

def insert_into_image_table(pg_cursor, image_key, metadata, s3_last_modified):
    file_created = get(metadata, 'file_created')
    if file_created:
        file_created = datetime.fromtimestamp(file_created)
    user_input_filename = get(metadata, 'user_input_filename')
    qr_code = get(metadata, 'qr_code')
    qr_codes = get(metadata, 'qr_codes')
    upload_device_id = get(metadata, 'upload_device_id')
    query = (
        "INSERT INTO image (s3_key_raw, image_timestamp, user_input_filename, qr_code, qr_codes, upload_device_id, s3_upload_timestamp)\n"
        "VALUES (%s, %s, %s, %s, %s, %s, %s);"
    )
    data = (image_key, file_created, user_input_filename, qr_code, qr_codes, upload_device_id, s3_last_modified)
    pg_cursor.execute(query, data)

def insert_into_image_match_table(pg_cursor, image_key, experiment_id, section_name):
    query = (
        "INSERT INTO image_match (s3_key_raw, experiment_id, section_name)\n"
        "VALUES (%s, %s, %s);"
    )
    data = (image_key, experiment_id, section_name)
    pg_cursor.execute(query, data)

def query_matching_experiments(pg_cursor, qr_code):
    query = (
        "SELECT experiment_id, section_name FROM experiment\n"
        "INNER JOIN greenhouse_box USING (experiment_id)\n"
        "INNER JOIN section USING (section_name)\n"
        "WHERE section_id = '{value}' OR section_name = '{value}';".format(value=qr_code)
    )
    pg_cursor.execute(query)
    results = pg_cursor.fetchall()
    return results
