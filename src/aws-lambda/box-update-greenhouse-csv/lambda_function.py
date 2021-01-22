import os
import json
import boxsdk
import psycopg2
import pandas

def lambda_handler(event, context):
    try:
        section_name = event['Records'][0]['section_name']
        run(section_name)
        return {'statusCode': 200, 'body': json.dumps('Hello from Lambda!')}
    except Exception as e:
        print(e)
        return {
            'statusCode': 400,
            'body': "sad life: " + str(e)
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
    query = (
        "SELECT greenhouse_box.experiment_id, experiment.box_csv_folder_id FROM greenhouse_box, experiment\n"
        "WHERE greenhouse_box.experiment_id = experiment.experiment_id AND section_name = '{}';".format(section_name)
    )
    cursor.execute(query)
    results = cursor.fetchall()
    for result in results:
        try:
            experiment_id, box_csv_folder_id = result[0], result[1]
            query = (
                "SELECT * FROM section_environment\n" + 
                "WHERE experiment_id = '{}'\n".format(experiment_id) + 
                "ORDER BY environment_timestamp ASC;"
            )
            df = pandas.io.sql.read_sql(query, connection)
            filename = "{experiment_id}-environment.csv".format(experiment_id=experiment_id)
            path = os.path.join("/tmp", filename)
            df.to_csv(path, index=False)
            upload(client, box_csv_folder_id, filename, path)
        except Exception as e:
            print(e)

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