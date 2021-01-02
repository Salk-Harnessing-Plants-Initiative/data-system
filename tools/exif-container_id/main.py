import pyexiv2
import json

def write():
	metadata = pyexiv2.ImageMetadata(filename)
	metadata.read()
	container_id = "taco"
	userdata = {"container_id" : container_id}
	metadata['Exif.Photo.UserComment'] = json.dumps(userdata)
	metadata.write()

def read():
	filename='/tmp/image.jpg'
	metadata = pyexiv2.ImageMetadata(filename)
	metadata.read()
	userdata=json.loads(metadata['Exif.Photo.UserComment'].value)
	pprint.pprint(userdata)

def move(src_path, dir):        
	dst_path = os.path.join(today_subdir, ntpath.basename(src_path))
    # Avoid collisions
    root_ext = os.path.splitext(dst_path)
    i = 0
    while os.path.isfile(dst_path):
        i += 1
        dst_path = root_ext[0] + " ({})".format(i) + root_ext[1]
    # Finally move file
    shutil.move(src_path, dst_path)

def main():

	# Open the file mapping

	# Get the list of files

	# Iterate through each file

		# Discern photo number by '_' delimiter

		# See if it fits in the mapping, else error

		# Write the container_id according to the mapping

		# Read to confirm it was written successfully

		# Move to parallel done directory

		# Record success for statistics

		# Log success

		# Move to parallel error diretory upon failure

		# Log failure

		# Record failure for statistics


        "/Volumes/groot-data/russell_tran/exif_pipeline/unprocessed/michel/Arabidopsis\ Plates-Take\'s\ 8/Take\'s\ 8_Round\ 2/10.08.20"