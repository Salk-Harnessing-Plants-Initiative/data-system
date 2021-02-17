import app
import unittest
import boto3

class Test(unittest.TestCase):

    def test_image_key_valid(self):
        self.assertFalse(app.image_key_valid("images/thumbnail/taco.png"))
        self.assertFalse(app.image_key_valid("images/thumbnail/taco.jpg"))
        self.assertFalse(app.image_key_valid("images/thumbnail/taco.jpeg"))
        self.assertFalse(app.image_key_valid("images/thumbnail/taco.tif"))
        self.assertFalse(app.image_key_valid("images/thumbnail/taco.tiff"))

        self.assertFalse(app.image_key_valid("images/raw/apple.png"))
        self.assertFalse(app.image_key_valid("images/raw/apple.PNG"))
        self.assertFalse(app.image_key_valid("images/raw/apple.pnG"))
        self.assertFalse(app.image_key_valid("images/raw/apple.jpg"))
        self.assertFalse(app.image_key_valid("images/raw/apple.jpeg"))
        self.assertFalse(app.image_key_valid("images/raw/apple.tif"))
        self.assertFalse(app.image_key_valid("images/raw/apple.tiff"))

        self.assertFalse(app.image_key_valid("image/plate/thumbnail/taco.png"))
        self.assertFalse(app.image_key_valid("image/plate/thumbnail/taco.jpg"))
        self.assertFalse(app.image_key_valid("image/plate/thumbnail/taco.jpeg"))
        self.assertFalse(app.image_key_valid("image/plate/thumbnail/taco.tif"))
        self.assertFalse(app.image_key_valid("image/plate/thumbnail/taco.tiff"))

        self.assertTrue(app.image_key_valid("image/plate/raw/apple.png"))
        self.assertTrue(app.image_key_valid("image/plate/raw/apple.PNG"))
        self.assertTrue(app.image_key_valid("image/plate/raw/apple.pnG"))
        self.assertTrue(app.image_key_valid("image/plate/raw/apple.jpg"))
        self.assertTrue(app.image_key_valid("image/plate/raw/apple.jpeg"))
        self.assertTrue(app.image_key_valid("image/plate/raw/apple.tif"))
        self.assertTrue(app.image_key_valid("image/plate/raw/apple.tiff"))

    """
    def test_download_image(self):
        client = boto3.client('s3')
        app.download_image(client, "salk-hpi", "images/thumbnail/1000px/_set1_day1_20201221-122406_005.jpg")
    """

    """
    def test_get_timestamp(self):
        s3_client = boto3.client('s3')
        bucket = "dev-salk-hpi"
        image_key = ""
        app.get_timestamp(s3_client, bucket, image_key, image)
    """

    def test_get_timestamp_from_filename(self):
        print(app.get_timestamp_from_filename("/Users/russelltran/Desktop/_set1_day1_20210126-091947_002.tif"))
        
if __name__ == '__main__':
    print(app.create_thumbnail_key("image/plate/raw/_set1_day1_20210126-091947_002.tif"))
    unittest.main()

    