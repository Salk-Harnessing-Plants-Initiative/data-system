/*
Salk Harnessing Plants Initiative
Helper functions for parsing time out of S3 files
Russell Tran
December 2020

You should note that for some scientific data files (namely, .tif images from 
Wolfgang's custom BRAT) the only timestamp might be in the name of the file,
so we have to parse it out of there.

- Parse timestamp out of EXIF metadata of .jpg and .tif files
- Parse timestamp out of S3 metadata that we put in there
- Parse timestamp out of file name
- Get upset if can't find a timestamp
- Logic to resolve who's the best timestamp or the most reasonable one

That we have these heuristics at all is a bit dangerous, but hopefully the probability
of catastrophe is low.
*/

// TODO: EVERYTHING

// As of Decembr 2020, Wolfgang's BRAT scanning system puts the timestamp
// in the format YYYYMMDD-HHMMSS somewhere in the filename