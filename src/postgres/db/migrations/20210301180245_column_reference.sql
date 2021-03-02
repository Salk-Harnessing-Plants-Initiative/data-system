-- migrate:up
CREATE TABLE public.column_reference
(
    column_table character varying NOT NULL,
    column_name character varying NOT NULL,
    column_type character varying NOT NULL,
    column_description character varying NOT NULL,
    PRIMARY KEY (column_table, column_name)
);

-- migrate:down

