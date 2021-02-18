# Salk HPI Data System
The main Salk HPI Data System for tracking plants and their phenotypic data in the lab, greenhouse, and field. Integrates with QR code tracking. Makes querying past experiments (+ images, etc.) and environmental data easier.

We don't currently have a wiki, so the best context for code is this readme and the readmes that are closest to each bit of code. However, there are some generally useful notes you can find here: https://www.notion.so/Salk-Harnessing-Plants-Initiative-Software-Engineering-Wiki-8b4c2524c41b4a4dae847a4b61cde92a

# Related repos

## S3 uploader services running as clients on imager computers
* https://github.com/Salk-Harnessing-Plants-Initiative/aws-s3-desktop-uploader: Used for uploading plate MultiScan images (.tif) to the data system
* https://github.com/Salk-Harnessing-Plants-Initiative/greenhouse-giraffe-uploader: Used for uploading top-down photos (.png) of greenhouse plants to the data system
* https://github.com/Salk-Harnessing-Plants-Initiative/plant-cylinder-uploader: Used for uploading rotational photos of plants grown in transparent cylinders

## Tools for researchers
* https://github.com/Salk-Harnessing-Plants-Initiative/excel-barcode-scanner-guide: Encode `plant_id` or `container_id` into a QR/barcode label and use a barcode scanner for rapid phenotypic data entry. The resultant spreadsheet can be uploaded to the data system
* https://github.com/Salk-Harnessing-Plants-Initiative/data-system-tools: Tools for cleaning data before uploading it into the data system, and tools for querying the data system for biocomputation research projects (e.g. stitching greenhouse Giraffe images for foliage analysis)

# Architecture

## S3 structure
`image/`:
* `giraffe/`:
	* `raw/`
* `plate/`:
	* `raw/`
	* `thumbnail/`
* `cylinder/`:
	* `raw/`:
		* `{plant_id}/`:
			* `{image_timestamp_date}/`

`tmp/`:
* `csv/`

## Greenhouse giraffe lambdas
Most of the other lambdas are not tied together in any complicated way, but since the greenhouse giraffe ones are a special case I've diagramed the relationship here for you in case it's helpful:
<img src="./doc/greenhouse_giraffe_lambdas.png" height="300"> 
