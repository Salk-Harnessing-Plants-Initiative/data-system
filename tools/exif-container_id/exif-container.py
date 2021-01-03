import json
import os
from os import path
from PIL import Image
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

def process(rows):
    # Open the file mapping

    # Get the list of files
    #print(get_preexisting_files("/Volumes/groot-data/russell_tran/exif_pipeline/unprocessed/michel/Arabidopsis\ Plates-Take\'s\ 8/Take\'s\ 8_Round\ 2/10.08.20"))
    dir = "/Volumes/groot-data/russell_tran/exif_pipeline/unprocessed/michel/Arabidopsis Plates-Take's 8/Take's 8_Round 2/10.08.20"
    files = os.listdir(dir)
    files = files = [f for f in files if not f[0] == '.']
    for file in files:
        path = os.path.join(dir, file)
        read_exif(path)
    # Iterate through each file

        # Discern photo number by '_' delimiter
        # .replace("_", ",").replace(".", ",").split(",")

        # See if it fits in the mapping, else error

        # Write the container_id according to the mapping

        # Read to confirm it was written successfully

        # Move to parallel done directory

        # Record success for statistics

        # Log success

        # Move to parallel error diretory upon failure

        # Log failure

        # Record failure for statistics


def main():
    path = "/Users/russelltran/Desktop/russell_bacon_0.tif"
    #path = "/Users/russelltran/Downloads/Arbitro.tiff"

    data = {
        "container_id" : "taco"
    }

    write_exif(path, path, data)
    print(read_exif(path))

if __name__ == "__main__":
    main()
        