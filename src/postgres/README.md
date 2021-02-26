# Postgres database
Hosted on AWS RDS Postgres.

## Database migration management
We use [dbmate](https://github.com/amacneil/dbmate) to handle our migrations.

# Quirks
* Important: For the table `section`, you should know that `section_id` is deprecated, and you should use `section_name` instead. If you're gonna make QR codes to identify a greenhouse or crop field section in the future, you can just go ahead and directly encode the `section_name` instead of the complicated `section_id` randomized string. There's basically no point in using `section_id` when you can identify a section using `section_name` instead.

## Role readaccess is needed for some client processes such as greenhouse-giraffe-uploader
```
CREATE ROLE readaccess;
GRANT USAGE ON SCHEMA public TO readaccess;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readaccess;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO readaccess;
```