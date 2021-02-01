import boxsdk
import uuid
import os
from datetime import datetime

def try_folder_id(folder_id, message=""):
    auth = boxsdk.JWTAuth.from_settings_file('box_config.json')
    client = boxsdk.Client(auth)
    box_folder = client.folder(folder_id=folder_id).get()
    items = [item for item in box_folder.get_items()]
    names = [item.name for item in items]

    path = os.path.join("/tmp", "{}.txt".format(str(uuid.uuid4())))
    box_filename = "data_system_connection_test.txt"

    if box_filename in names:
        for item in items:
            if box_filename == item.name:
                with open(path, 'wb') as output_file:
                    client.file(item.id).download_to(output_file)
                with open(path, "a") as f:
                    put_stuff(f, message)
                item.update_contents(path)
    else:
        with open(path, "a") as f:
            put_stuff(f, message)
        box_folder.upload(path, box_filename)

    print("Tried folder_id {}".format(folder_id))

def put_stuff(f, message):
    f.write(datetime.now().astimezone().isoformat())
    f.write(" " + message)
    f.write("\n")