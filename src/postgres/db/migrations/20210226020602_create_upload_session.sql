-- migrate:up
ALTER TABLE image
ADD COLUMN upload_session character varying;

-- migrate:down

