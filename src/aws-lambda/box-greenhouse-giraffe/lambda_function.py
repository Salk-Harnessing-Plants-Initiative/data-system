# TODO : {'key': 'image/giraffe/raw/IMG_5751+%281%29-593d8390-b03f-4fc3-a230-26a3a3261163.jpg' bug 
import os
import io
import json
import boxsdk
import psycopg2
import boto3
from datetime import datetime
import traceback

def lambda_handler(event, context):
    print("Event: ", event)
    for record in event['Records']:
        try:
            bucket = record['s3']['bucket']['name']
            image_key = record['s3']['object']['key']
            process(bucket, image_key)
        except Exception as e:
            traceback.print_exc()
            print("Error: ", repr(e))

def process(bucket, image_key):
    box_client = boxsdk.Client(boxsdk.JWTAuth.from_settings_file('box_config.json'))
    s3_client = boto3.client('s3')
    pg_cursor = psycopg2.connect(
        user=os.environ['user'],
        password=os.environ['password'],
        host=os.environ['host'],
        port=os.environ['port'],
        database=os.environ['database']).cursor()

    with open('config.json') as f:
        config = json.load(f)

    if not image_key_valid(image_key, config):
        raise Exception("Image key '{}' invalid for filter".format(image_key))
    metadata = s3_client.head_object(Bucket=bucket, Key=image_key)['Metadata']
    results = query_matching_box_csv_folder_ids(pg_cursor, metadata['qr_code'])
    if len(results) > 0:
        image_bytes = s3_client.get_object(Bucket=bucket, Key=image_key)['Body'].read()
        do_box_processing(box_client, results, config, metadata, image_bytes)

def image_key_valid(image_key, config):
    """Safety filter to ensure we are only processing files from 
    the correct directory in the bucket
    """
    return (os.path.dirname(image_key) == config['s3']['src_dir'])

def query_matching_box_csv_folder_ids(pg_cursor, qr_code):
    query = (
        "SELECT box_image_folder_id, experiment_id, section_name FROM experiment\n"
        "INNER JOIN greenhouse_box USING (experiment_id)\n"
        "INNER JOIN section USING (section_name)\n"
        "WHERE section_id = '{value}' OR section_name = '{value}';".format(value=qr_code)
    )
    pg_cursor.execute(query)
    results = pg_cursor.fetchall()
    return results

def do_box_processing(box_client, results, config, metadata, image_bytes):
    file_created = metadata['file_created']
    user_input_filename = metadata['user_input_filename']
    use_date_subfolder = config['box']['use_date_subfolder']
    use_section_subfolder = config['box']['use_section_subfolder']

    used_folder_ids = set()
    for result in results:
        box_image_folder_id, experiment_id, section_name = result[0], result[1], result[2]

        # Check the box_image_folder_id isn't null
        if not box_image_folder_id:
            print("There was no box_image_folder_id for experiment_id={}, section_name={}, so skipping...".format(
                experiment_id, section_name))
            continue
        # Check for duplicates
        if box_image_folder_id in used_folder_ids:
            print("box_image_folder_id {} was already used, so skipping for experiment_id={}, section_name={}".format(
                box_image_folder_id, experiment_id, section_name))
            continue
        used_folder_ids.add(box_image_folder_id)

        # Upload a copy of the image to Box
        image_stream = io.BytesIO(image_bytes)
        upload_to_box(box_client, box_image_folder_id, image_stream, user_input_filename,
            file_creation_timestamp = file_created if use_date_subfolder else None,
            section_name = section_name if use_section_subfolder else None
        )    

def upload_to_box(box_client, box_folder_id, file_stream, dst_filename,
    file_creation_timestamp=None, section_name=None):
    """Upload image_stream to some subfolder of box_folder_id as dst_filename.
    If file_creation_timestamp is provided, then a date subfolder will be used.
    If section_name is provided, then a section subfolder will also be used.
    """
    root_folder = box_client.folder(folder_id=box_folder_id).get()
    current_folder = root_folder

    if file_creation_timestamp is not None:
        file_creation_date = datetime.fromisoformat(file_creation_timestamp).strftime('%Y-%m-%d')
        current_folder = get_box_subfolder(current_folder, file_creation_date)

    if section_name is not None:
        current_folder = get_box_subfolder(current_folder, section_name)

    current_folder.upload_stream(file_stream, dst_filename)

def get_box_subfolder(box_folder, subfolder_name):
    subfolders = [item for item in box_folder.get_items() if type(item) == boxsdk.object.folder.Folder]
    subfolder_names = [subfolder.name for subfolder in subfolders]
    if subfolder_name not in subfolder_names:
        subfolder = box_folder.create_subfolder(subfolder_name)
        return subfolder
    else:
        for subfolder in subfolders:
            if subfolder.name == subfolder_name:
                return subfolder
