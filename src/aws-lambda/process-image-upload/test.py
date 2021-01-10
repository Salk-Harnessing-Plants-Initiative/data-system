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

    	self.assertTrue(app.image_key_valid("images/raw/apple.png"))
    	self.assertTrue(app.image_key_valid("images/raw/apple.PNG"))
    	self.assertTrue(app.image_key_valid("images/raw/apple.pnG"))
    	self.assertTrue(app.image_key_valid("images/raw/apple.jpg"))
    	self.assertTrue(app.image_key_valid("images/raw/apple.jpeg"))
    	self.assertTrue(app.image_key_valid("images/raw/apple.tif"))
    	self.assertTrue(app.image_key_valid("images/raw/apple.tiff"))

    def test_download_image(self):
    	client = boto3.client('s3')
    	app.download_image(client, "salk-hpi", "images/thumbnail/1000px/_set1_day1_20201221-122406_005.jpg")
        

        
if __name__ == '__main__':
    unittest.main()
    