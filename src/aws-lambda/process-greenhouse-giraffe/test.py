import unittest
import os
import boto3
import psycopg2
import lambda_function
from datetime import datetime

class Test(unittest.TestCase):

    def test_insert_into_image_table(self):
        print("Trying its best....")
        pg_conn = psycopg2.connect(
            user=os.environ['user'],
            password=os.environ['password'],
            host=os.environ['host'],
            port=os.environ['port'],
            database=os.environ['database'])
        pg_conn.autocommit = True
        pg_cursor = pg_conn.cursor()
        lambda_function.insert_into_image_table(pg_cursor, "hello/world/my/name/is/ron.jpg", {}, datetime.now())

    def test_insert_into_image_match_table(self):
        pass

        
if __name__ == '__main__':
    unittest.main()
    