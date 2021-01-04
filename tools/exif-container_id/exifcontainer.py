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
    # Finally move file

    os.makedirs(directoriesindapath, exist_ok=True)


    shutil.move(src_path, dst_path)

def get_preexisting_files(dir):
    """Recursively get all filenames in a directory
    Returns them as a list of paths
    """
    print(dir)
    preexisting = []
    for root, dirs, files in os.walk(dir):
        print(root)
        print(dirs)
        print(files)
        # Ignore hidden files
        files = [f for f in files if not f[0] == '.']
        for file in files:
            preexisting.append(os.path.join(root, file))
    return sorted(preexisting)

def process(container_df, directory_map):
    unprocessed_dir = directory_map["unprocessed"]
    error_dir = directory_map["error"]
    done_dir = directory_map["done"]
    # Get the list of tif images in the "unprocessed" dir
    files = os.listdir(unprocessed_dir)
    files = sorted([f for f in files if not f[0] == '.']) # Ignore hidden files

    # Iterate through each file
    for file in files:
        path = os.path.join(unprocessed_dir, file)

        # Discern photo number by '_' delimiter
        print(file.replace("_", ",").replace(".", ",").split(","))
        #photo_number = int(file.replace("_", ",").replace(".", ",").split(","))

        # See if it fits in the mapping, else error

        # Write the container_id according to the mapping

        # Read to confirm it was written successfully

        # Move to parallel done directory

        # Record success for statistics

        # Log success

        # Move to parallel error diretory upon failure

        # Log failure

        # Record failure for statistics
        data = {
            "container_id" : "taco"
        }

def run(container_csv, directory_json, output_log=None):
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
        directory_maps = json.load(json_file)["mappings"]
        container_df = pd.read_csv(container_csv)
        for directory_map in directory_maps:
            process(container_df, directory_map)

if __name__ == "__main__":
    print("You should import this instead of run directly")
        