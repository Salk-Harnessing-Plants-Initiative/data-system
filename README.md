# Salk HPI Data System
The main Salk HPI Data System for tracking plants and their phenotypic data in the lab, greenhouse, and field. Integrates with QR code tracking. Makes querying past experiments (+ images, etc.) and environmental data easier.

The wiki can be found here: https://www.notion.so/Salk-Harnessing-Plants-Initiative-Software-Engineering-Wiki-8b4c2524c41b4a4dae847a4b61cde92a

# Related repos

## S3 uploader services running as clients on imager computers
* https://github.com/Salk-Harnessing-Plants-Initiative/aws-s3-desktop-uploader: Used for uploading plate MultiScan images (.tif) to the data system
* https://github.com/Salk-Harnessing-Plants-Initiative/greenhouse-giraffe-uploader: Used for uploading top-down photos (.png) of greenhouse plants to the data system
* https://github.com/Salk-Harnessing-Plants-Initiative/plant-cylinder-uploader: Used for uploading rotational photos of plants grown in transparent cylinders

## Tools for researchers
* https://github.com/Salk-Harnessing-Plants-Initiative/excel-barcode-scanner-guide: Encode `plant_id` or `container_id` into a QR/barcode label and use a barcode scanner for rapid phenotypic data entry. The resultant spreadsheet can be uploaded to the data system
* https://github.com/Salk-Harnessing-Plants-Initiative/data-system-tools: Tools for cleaning data before uploading it into the data system, and tools for querying the data system for biocomputation research projects (e.g. stitching greenhouse Giraffe images for foliage analysis)
