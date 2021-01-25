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
    insert_into_image_table(pg_cursor, image_key, metadata)
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
        return ""

def insert_into_image_table(pg_cursor, image_key, metadata):
    file_created = get(metadata, 'file_created')
    user_input_filename = get(metadata, 'user_input_filename')
    qr_code = get(metadata, 'qr_code')
    qr_codes = get(metadata, 'qr_codes')
    upload_device_id = get(metadata, 'upload_device_id')
    query = (
        "INSERT INTO image (s3_key_raw, image_timestamp, user_input_filename, qr_code, qr_codes, upload_device_id)\n"
        "VALUES ('{}', '{}', '{}', '{}', '{}', '{}');".format(
            image_key, file_created, user_input_filename, qr_code, qr_codes, upload_device_id
        )
    )
    pg_cursor.execute(query)

def insert_into_image_match_table(pg_cursor, image_key, experiment_id, section_name):
    query = (
        "INSERT INTO image_match (s3_key_raw, experiment_id, section_name)\n"
        "VALUES ('{}', '{}', '{}');".format(
            image_key, experiment_id, section_name
        )
    )
    pg_cursor.execute(query)

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
