# Salk HPI Data System
The main Salk HPI Data System for tracking plants and their phenotypic data in the lab, greenhouse, and field. Integrates with QR code tracking. Makes querying past experiments (+ images, etc.) and environmental data easier.

We don't currently have a wiki, so the best context for code is this readme and the readmes that are closest to each bit of code. However, there are some generally useful notes you can find here: https://www.notion.so/Salk-Harnessing-Plants-Initiative-Software-Engineering-Wiki-8b4c2524c41b4a4dae847a4b61cde92a

Concept as of March 2021: https://docs.google.com/presentation/d/1EFnYIE4aLeLNuLu7ud0ikeX_zSn1_6kez7k2p-ynouQ/edit?usp=sharing

# Related repos

## S3 uploader services running as clients on imager computers
* https://github.com/Salk-Harnessing-Plants-Initiative/plant-independent-image-uploader: Used for uploading plate MultiScan images (.tif) and normal standalone images (e.g. pot images) to the data system
* https://github.com/Salk-Harnessing-Plants-Initiative/greenhouse-giraffe-uploader: Used for uploading top-down photos (.png) of greenhouse plants to the data system
* https://github.com/Salk-Harnessing-Plants-Initiative/plant-cylinder-uploader: Used for uploading rotational photos of plants grown in transparent cylinders
* https://github.com/Salk-Harnessing-Plants-Initiative/aws-s3-desktop-uploader: Deprecated; use plant-independent-image-uploader.

## Tools for researchers
* https://github.com/Salk-Harnessing-Plants-Initiative/excel-barcode-scanner-guide: Encode `plant_id` or `container_id` into a QR/barcode label and use a barcode scanner for rapid phenotypic data entry. The resultant spreadsheet can be uploaded to the data system
* https://github.com/Salk-Harnessing-Plants-Initiative/DSLR-camera-barcode-imaging-guide: Used in deep rooting project, for example
* https://github.com/Salk-Harnessing-Plants-Initiative/data-system-tools: Tools for cleaning data before uploading it into the data system, and tools for querying the data system for biocomputation research projects (e.g. stitching greenhouse Giraffe images for foliage analysis)
* https://github.com/Salk-Harnessing-Plants-Initiative/nsipptparser: Simple Python package to parse `.nsippt` files which are files that contain length annotation measurements from slice plane "Views" of North Star Imaging X-ray reconstructions. Basically you can open reconstruction files (e.g., `.nsihdr`) using North Star Imaging's analysis software tool and measure root lengths. (The equivalent of ImageJ). You can Export the root length measurements by exporting the View, and the output file type is `.nsippt`. This Python package will convert `.nsippt` to JSON for you. You will be able to extract any of the length measurements as well as a useful thumbnail of the View in base64. 

# Architecture
<img src="./doc/flow.jpeg" height="400"> 


*(Concept of architecture, not up-to-date reflection)*  

We use Postgres for our database, AWS Lambda for the backend, Retool for the frontend, and have various scripts running on client computers to upload images.


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


## QR code integration
One of the main features of this data system is its ability to process QR codes to automate some of our processes. QR codes are conceptually simple in the sense that you can technically encode any string you want into them. For our purposes, we **strictly** encode an ID into the QR code (and **not** arbitrary metadata) so that the code can be integrated with the rest of our data system in a very logical manner. 


<img src="./doc/plate_barcode_example.jpg" height="500"> 

### Explained: plant_id vs container_id vs section_name
This might be a little confusing at first, but basically we have 3 different categories of QR codes for use in different contexts to integrate all the diverse data we work with.

* **`plant_id`** is the globally unique identifier of a literal plant individual/organism. It's a 1:1 relationship. If you have 1 seedling or 1 corn stalk, the `plant_id` is just for that seedling or corn stalk. Not for a species, not for a variety, not for a line or accession.

* **`container_id`** is the globally unique identifier of the container some plant(s) are grown in. Such as an agar plate, a plastic cylinder, a pocket of a tray, or a plastic pot. This is the container where you are actually growing the plant(s) for the experiment, so if you're sprouting the seedlings somewhere and then transferring them to a container, we are referring to the post-transfer container. 
	* A `plant_id` can only have one `container_id` (and they're associated when the IDs are originally generated), but a `container_id` can have multiple `plant_id`s. So if you have an agar plate with 12 seedlings in it, for instance, each seedling will have a `plant_id`, and all of those `plant_id`s will be hard linked to a single `container_id`. (There's a thing called a `containing_index` which tells you the relative location of a `plant_id` inside a `container_id`).

* **`section_name`** is the identifier of a partition of a greenhouse or outdoor crop field. It is constant and exists regardless of what plants are growing on it. A good example of this is each growing table in the Encinitas greenhouse, such as `EG-01-01`,..., `EG-01-10`, ..., `EG-04-01`,..., `EG-04-10`. Another example of this might be various subplots of land where we would do a field study. Though the plants may come and go, the `section_name` of a particular growing table stays the same. (Never use `section_id` which is deprecated/legacy).

#### Rules

The thing is that we use QR codes both as a way to automatically sort our images and as a barcode that you can scan with a handheld barcode scanner. Sometimes these goals are at odds with each other, which is how it's led us to the following rules about which class of QR codes should get encoded: 

* If you are working with agar plates, you should always encode the `container_id` as the QR code on the label during label-printing. (This comes from the design consideration that agar plates almost always have many seedlings growing in them. And also that people only do digital--not physical--phenotyping of agar plates, so nobody is using a handheld barcode scanner). **All agar plate image scans will only be sorted by `container_id`-based QR codes.** 

* If you are working with plastic cylinders or normal plant pots, you should almost always encode the `plant_id` as the QR code on the label, and ensure that you have one label for each plant. This is because someone will likely be using a handheld barcode scanner to scan each plant when doing physical phenotypic measurements and manual data entry. However, **all cylinder images, 3D scan images, and X-ray images will be capable of being sorted by both `plant_id` and `container_id`-based QR codes.** 
	* This is just to make life easier because the people who do plates+cylinders will be used to using `container_id`, whereas the people who do physical phenotyping will be used to using `plant_id`.
	* But as a developer working on this data system, you should know that all images with the exception of Greenhouse Giraffe images should ultimately get identified by `container_id` in order to make querying easy and unified later. (So transform given `plant_id`s to `container_id` on the backend). 

* If you are imaging entire partitions of a greenhouse or crop field, encode `section_name` as the QR code used on signs to identify the section. For instance, in the Encinitas greenhouse we use `section_name` as the QR code on big laminated signs so that when we take top-down images of the growing tables using the Greenhouse Giraffe or otherwise, the images get associated with that section. **All Greenhouse Giraffe images will only be sorted by `section_name`-based QR codes.** 

#### plant_id vs container_id vs section_name and Rules, rewritten by ChatGPT 01/28/2023

This code documentation explains the different types of QR codes used in the system and their respective uses.

Plant_id is a unique identifier for a single plant. It is used to identify a specific plant and is not related to a species, variety, or accession.
Container_id is a unique identifier for the container where a plant is grown. This could be an agar plate, plastic cylinder, or pot. A container_id can have multiple plant_ids associated with it, but a plant_id can only have one container_id.
Section_name is an identifier for a specific section of a greenhouse or outdoor crop field. It is constant and remains the same regardless of the plants in that section.
When working with agar plates, the container_id should be encoded as the QR code on the label during label-printing. This is because agar plates often have many seedlings growing in them and the images will be sorted by container_id-based QR codes. When working with plastic cylinders or normal plant pots, the plant_id should be encoded as the QR code on the label, as someone will likely be using a handheld barcode scanner to scan each plant when doing physical phenotypic measurements and manual data entry. However, all cylinder images, 3D scan images, and X-ray images will be capable of being sorted by both plant_id and container_id-based QR codes.

When imaging entire partitions of a greenhouse or crop field, the section_name should be encoded as the QR code used on signs to identify the section. This is used when taking top-down images of the growing tables using a device such as the Greenhouse Giraffe. All Greenhouse Giraffe images will only be sorted by section_name-based QR codes.

As a developer working on this data system, it is important to know that all images with the exception of Greenhouse Giraffe images should ultimately get identified by container_id in order to make querying easy and unified later. If needed, plant_ids should be transformed to container_id on the backend.

# Manual migration of plate Excel spreadsheet to data system

<img src="./doc/retool_database_editor.png" height="500"> 

As an admin, you may have to do this as a favor to biologists in order to get their spreadsheet data into the database.

1. Manually copy `plant_metadata` and `line_accession_metadata` sheets from the `.xlsx` into 2 independent `CSV` files. E.g. `plant_metadata.csv` and `line_accession_metadata.csv`. You don't need to touch `container_metadata`.

2. Clean the data. Scrub duplicates, remove invalid or extraneous columns (e.g. `notes` or `plant_abbrev` columns), replace "N/A" with null, correct dates.

3. Upload `line_accession_metadata.csv` into the table `line_accession` first using the Retool Database Editor. You must use `line_accession` as the primary key.

4. Upload `plant_metadata.csv` into the table `plant` using the Retool Database Editor. You must use `plant_id` as the primary key. 

5. Update the [data migration log](https://github.com/Salk-Harnessing-Plants-Initiative/data-system/releases/) (we are using Github releases to track this, which is kind of janky for now but oh well).

# How to print QR code labels using Brady
1) Create a custom label in Brady
2) Import spreadsheet
3) Place the container_id column as QR CODE (it'll generate from the values) 
4) Place the container_id_abbrev as TEXT
5) Place 1_line_accession as TEXT to represent the top half
6) Place 2_line_accession as TEXT to represent the bottom half
7) Place the treatment column as TEXT to show the treatment

Best bet is to follow the spatial arrangement that the previous labels used as an example

The Retool site should have a link to a tutorial video as of January 2022
