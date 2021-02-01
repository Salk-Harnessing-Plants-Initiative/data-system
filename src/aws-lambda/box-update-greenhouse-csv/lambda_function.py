import os
import json
import boxsdk
import psycopg2
import pandas
import try_box

def lambda_handler(event, context):
    try:
        if 'try_box' in event and event['try_box'] == True:
            try_box.try_folder_id(event['try_box_folder_id'], 
                message="" if 'message' not in event else event['message'])
            return {'statusCode': 200, 'body': json.dumps('Trying the box folder took place')}
        else:
            section_name = event['section_name']
            run(section_name)
            return {'statusCode': 200, 'body': json.dumps('CSV updating took place')}
    except Exception as e:
        print(repr(e))
        return {
            'statusCode': 400,
            'body': "sad life: " + repr(e)
        }

def run(section_name):
    auth = boxsdk.JWTAuth.from_settings_file('box_config.json')
    client = boxsdk.Client(auth)
    connection = psycopg2.connect(
        user=os.environ['user'],
        password=os.environ['password'],
        host=os.environ['host'],
        port=os.environ['port'],
        database=os.environ['database']
    )
    cursor = connection.cursor()
    # Get all experiments currently linked to this section
    query = (
        "SELECT greenhouse_box.experiment_id, experiment.box_csv_folder_id FROM greenhouse_box, experiment\n"
        "WHERE greenhouse_box.experiment_id = experiment.experiment_id AND section_name = '{}';".format(section_name)
    )
    cursor.execute(query)
    results = cursor.fetchall()
    # For each experiment, query from scratch all their sections' environment records
    # And then dump that in the experiment's Box designated folder (box_csv_folder_id)
    for result in results:
        try:
            experiment_id, box_csv_folder_id = result[0], result[1]
            query = (
                "SELECT experiment_id, section_name, environment_timestamp, emitter_ec_ms_cm, emitter_ph, emitter_volume_ml, leach_ec_ms_cm, leach_ph, leach_volume_ml FROM section_environment\n" + 
                "WHERE experiment_id = '{}'\n".format(experiment_id) + 
                "ORDER BY environment_timestamp ASC;"
            )
            df = pandas.io.sql.read_sql(query, connection)
            df['environment_timestamp'] = df['environment_timestamp'].dt.tz_convert('America/Los_Angeles')
            # Dump
            filename = "{experiment_id}-environment.csv".format(experiment_id=experiment_id)
            path = os.path.join("/tmp", filename)
            df.to_csv(path, index=False)
            # Push
            upload(client, box_csv_folder_id, filename, path)
        except Exception as e:
            print(repr(e))

def upload(box_client, box_folder_id, box_filename, path):
    box_folder = box_client.folder(folder_id=box_folder_id).get()
    items = [item for item in box_folder.get_items()]
    names = [item.name for item in items]
    if box_filename not in names:
        box_folder.upload(path, 
            file_description="Don't move or edit this file as a bot will periodically update it. Make a copy instead.")
    else:
        for item in items:
            if box_filename == item.name:
                item.update_contents(path)
                return

if __name__ == "__main__":
    run("EG-01-01")