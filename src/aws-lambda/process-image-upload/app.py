import json
from pyzbar.pyzbar import decode
from PIL import Image

def lambda_handler(event, context):
    # TODO implement
    print(decode(Image.open("taco.png")))
    print(decode(Image.open("russell_bacon_0.tif")))
    return {
        'statusCode': 200,
        'body': json.dumps('Hello from Lambda!')
    }
