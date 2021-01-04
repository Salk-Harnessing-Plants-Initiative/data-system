import json
import os
from os import path
from PIL import Image
import pandas as pd
import logging

# Use the UserComment field, since manufacturers et al. leave it empty
# https://www.awaresystems.be/imaging/tiff/tifftags/privateifd/exif/usercomment.html
EXIF_USERCOMMENT = 37510

def write_exif(src_path, dst_path, json_dict):
    """Write json (dictionary)
    """
    write_exif_string(src_path, dst_path, json.dumps(json_dict))

def write_exif_string(src_path, dst_path, string):
    """Write a string
    """
    image = Image.open(src_path)
    image.tag[EXIF_USERCOMMENT] = string
    image.save(dst_path, tiffinfo=image.tag)

def read_exif(path):
    """Returns json (dictionary)
    """
    return json.loads(read_exif_string(path))

def read_exif_string(path):
    """Returns a string
    """
    with Image.open(path) as image:
        return image.tag[EXIF_USERCOMMENT][0]

def move(src_path, dst_path):        
    # Avoid collisions if file already exists at dst_path
    # Format the same way filename collisions are resolved in Google Chrome downloads
    root_ext = os.path.splitext(dst_path)
    i = 0
    while os.path.isfile(dst_path):
        # Recursively avoid the collision
        i += 1
    dst_path = root_ext[0] + " ({})".format(i) + root_ext[1]

    # Finally move file, make directories if needed
    os.makedirs(os.path.dirname(dst_path), exist_ok=True)
    shutil.move(src_path, dst_path)

def photo_numbers_unique(dir):
    files = os.listdir(dir)
    files = sorted([f for f in files if not f[0] == '.']) # Ignore hidden files
    photo_numbers = []
    for file in files:
        photo_number = int(file.replace("_", ",").replace(".", ",").split(",")[-2])
        photo_numbers.append(photo_number)
    return pd.Series(photo_numbers).is_unique

def container_id_data(row):
    return { "container_id" : row["container_id"] }

def process(container_df, directory_map, get_data):
    unprocessed_dir = directory_map["unprocessed"]
    error_dir = directory_map["error"]
    done_dir = directory_map["done"]

    logging.info("==============================================")
    logging.info("Processing photos with unprocessed = {}\nerror = {}\ndone = {}".format(
        unprocessed_dir, error_dir, done_dir))
    if not photo_numbers_unique(unprocessed_dir):
        logging.error("Photo numbers in directory {} were not unique. Skipping this directory...".format(unprocessed_dir))
        return

    # Start the accounting off with empty strings
    # accounting = pd.Series(["" for i in range(len(container_df[unprocessed_dir]))],
    #    index=container_df[unprocessed_dir].values)
    accounting = {}

    # Iterate through each tif file
    files = os.listdir(unprocessed_dir)
    files = sorted([f for f in files if not f[0] == '.']) # Ignore hidden files
    logging.info("Got files: " + str(files))
    for file in files:
        path = os.path.join(unprocessed_dir, file)
        try:
            photo_number = int(file.replace("_", ",").replace(".", ",").split(",")[-2])

            # See if it fits in the mapping, else error
            selection = container_df[container_df[unprocessed_dir] == photo_number]
            num_rows = len(selection.index)
            if (num_rows != 1):
                raise Exception("Got {} rows for photo_number {} in {}".format(num_rows, photo_number, unprocessed_dir))
            row = selection.iloc[0]

            # Write the container_id according to the mapping
            data = get_data(row)
            logging.info("Writing exif for {}...".format(file))
            write_exif(path, path, data)
            if read_exif(path) != data:
                raise Exception("storing custom data in exif failed or was corrupted for {}".format(path))

            # Success
            move(path, os.path.join(done_dir, file))
            accounting[file] = "success"
            logging.info("Successfully processed {}".format(path))

        except Exception as e:
            move(path, os.path.join(error_dir, file))
            accounting[file] = "failure"
            logging.error("Failed to process {} : {}".format(path, str(e)))

    result = pd.Series(accounting)
    logging.info("Totals:\n" + str(result.sum()))
    logging.info("Successes:\n" + str(result[result == "success"]))
    logging.info("Failures:\n" + str(result[result == "failure"]))

            
def check_unique(df):
    for label, content in df.items():
        if not content.is_unique:
            raise Exception("Column {} in csv is not unique".format(label))

def check_missing(df):
    for label, content in df.items():
        if content.isnull().values.any():
            raise Exception("Column {} in csv is missing a value".format(label))

def check_directory_maps(directory_maps):
    for dm in directory_maps:
        if ("unprocessed" not in dm) or ("error" not in dm) or ("done" not in dm):
            raise Exception("Directory maps missing something") 

def check_mappings(container_df, directory_maps):
    header = container_df.columns
    for directory_map in directory_maps:
        if directory_map["unprocessed"] not in header:
            raise Exception("Unprocessed dir {} in directory maps is not in container_csv")

def run(container_csv, directory_json, get_data, output_log=None):
    log_handlers = [logging.StreamHandler()]
    if output_log is not None:
        log_handlers.append(logging.FileHandler(output_log))
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(message)s",
        handlers=log_handlers
    )

    # Iterate through each directory map under "mappings" in the json
    with open(directory_json) as json_file:
        container_df = pd.read_csv(container_csv)
        check_unique(container_df)
        check_missing(container_df)

        directory_maps = json.load(json_file)["mappings"]
        check_mappings(container_df, directory_maps)
        for directory_map in directory_maps:
            process(container_df, directory_map, get_data)

if __name__ == "__main__":
    print("You should import this instead of run directly")
        