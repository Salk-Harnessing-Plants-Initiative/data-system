import os
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


import psycopg2
from psycopg2 import Error

try:
    # Connect to an existing database
    connection = psycopg2.connect(user=os.environ['user'],
                                  password=os.environ['password'],
                                  host=os.environ['host'],
                                  port=os.environ['port'],
                                  database=os.environ['database'])

    # Create a cursor to perform database operations
    cursor = connection.cursor()
    # Print PostgreSQL details
    print("PostgreSQL server information")
    print(connection.get_dsn_parameters(), "\n")
    # Executing a SQL query
    cursor.execute("SELECT version();")
    # Fetch result
    record = cursor.fetchone()
    print("You are connected to - ", record, "\n")

except (Exception, Error) as error:
    print("Error while connecting to PostgreSQL", error)
finally:
    if (connection):
        cursor.close()
        connection.close()
        print("PostgreSQL connection is closed")