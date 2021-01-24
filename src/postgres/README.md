# Postgres database
* Important: For the table `section`, you should know that `section_id` is deprecated, and you should use `section_name` instead. If you're gonna make QR codes to identify a greenhouse or crop field section in the future, you can just go ahead and directly encode the `section_name` instead of the complicated `section_id` randomized string. There's basically no point in using `section_id` when you can identify a section using `section_name` instead.

* Mappings of where to find contiguous top-down images of greenhouse plants in AWS S3. You take the key_template and all the contiguous photos are in 1-indexed ascending order. E.g. "images/raw/NVJsjnc/beautiful_morning" means the look in NVJsinc for "beautiful_morning_1.png", "beautiful_morning_2.png", etc. Time is the timestamp of the first image in the cluster.

# Create role readaccess before (querying using the copy-pasted contents of `create.sql`):
```
CREATE ROLE readaccess;
GRANT USAGE ON SCHEMA public TO readaccess;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readaccess;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readaccess;
```