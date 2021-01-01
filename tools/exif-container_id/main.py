import pyexiv2
import json

metadata = pyexiv2.ImageMetadata(filename)
metadata.read()
userdata={'Category':'Human',
          'Physical': {
              'skin_type':'smooth',
              'complexion':'fair'
              },
          'Location': {
              'city': 'london'
              }
          }
metadata['Exif.Photo.UserComment']=json.dumps(userdata)
metadata.write()

"""
import pprint
filename='/tmp/image.jpg'
metadata = pyexiv2.ImageMetadata(filename)
metadata.read()
userdata=json.loads(metadata['Exif.Photo.UserComment'].value)
pprint.pprint(userdata)
"""