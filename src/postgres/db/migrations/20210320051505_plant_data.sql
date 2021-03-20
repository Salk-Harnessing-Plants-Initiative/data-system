-- migrate:up
CREATE TABLE public.plant_data
(
    plant_id character varying NOT NULL,
    data_timestamp timestamp with time zone NOT NULL,
    height_cm numeric,
    PRIMARY KEY (plant_id, data_timestamp)
);

-- migrate:down

