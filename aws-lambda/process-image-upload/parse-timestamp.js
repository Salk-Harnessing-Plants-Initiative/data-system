/*
Salk Harnessing Plants Initiative
Helper functions for parsing time out of S3 files
Russell Tran
December 2020

You should note that for some scientific data files (namely, .tif images from 
Wolfgang's custom BRAT) the only timestamp might be in the name of the file,
so we have to parse it out of there. As of December 2020, Wolfgang's BRAT 
scanning system puts the timestamp in the format YYYYMMDD-HHMMSS somewhere in the filename.

Order of priority in resolving timestamp. Try for the next timestamp IF no timestamp found OR
timestamp parsed is beginning of the time epoch (invalid):
- Parse timestamp out of EXIF metadata of .jpg and .tif files
- Parse timestamp out of file name (explicitly ONLY YYYYMMDD-HHMMSS as substring of filename)
- Parse timestamp out of S3 metadata that we put in there using one of our custom uploader clients
	("file_created")

That we have these heuristics at all is a bit dangerous, but hopefully the probability
of catastrophe is low.
*/

// TODO: EVERYTHING
// TODO - Get upset if can't find a timestamp

const exiftool = require("exiftool-vendored").exiftool

async function parse_timestamp_from_exif(file_path) {

	try {
		const tags = await exiftool.read(file_path);
		// These fields are basically the same
		return tags.DateTimeOriginal.rawValue ? tags.DateTimeOriginal.rawValue : tags.CreateDate.rawValue
	} catch (error) {
		throw error;
	}
}

parse_timestamp_from_exif("/Users/russelltran/Desktop/Panasonic_DMC-FZ30.jpg").then(data => console.log(data)).catch(error => console.log(error));
