SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: column_reference; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.column_reference (
    column_table character varying NOT NULL,
    column_name character varying NOT NULL,
    column_type character varying NOT NULL,
    column_description character varying NOT NULL
);


--
-- Name: container; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.container (
    container_type character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying,
    experiment_id character varying NOT NULL,
    container_id character varying NOT NULL
);


--
-- Name: experiment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.experiment (
    experiment_id character varying NOT NULL,
    species character varying NOT NULL,
    scientist character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    description character varying,
    created_by character varying,
    box_image_folder_id character varying,
    box_csv_folder_id character varying,
    experiment_name character varying
);


--
-- Name: greenhouse_box; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.greenhouse_box (
    section_name character varying NOT NULL,
    experiment_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying
);


--
-- Name: TABLE greenhouse_box; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.greenhouse_box IS 'Mappings to greenhouse Box folders';


--
-- Name: image; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image (
    s3_key_raw character varying NOT NULL,
    s3_key_thumbnail character varying,
    created_by character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_input_filename character varying,
    image_timestamp timestamp with time zone,
    qr_code character varying,
    upload_device_id character varying,
    qr_codes character varying,
    s3_upload_timestamp timestamp with time zone,
    upload_session character varying
);


--
-- Name: COLUMN image.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.image.created_at IS 'Pay special attention to the fact that this refers to the time at which this entry was created in the database, NOT the file creation time';


--
-- Name: COLUMN image.qr_codes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.image.qr_codes IS 'List of all QR codes present in the image (optional use for the crazy case where multiple have been detected). Formatted as a stringified list. E.g. ["apple", "banana"]';


--
-- Name: image_match; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.image_match (
    s3_key_raw character varying NOT NULL,
    experiment_id character varying NOT NULL,
    container_id character varying,
    section_name character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    plant_id character varying
);


--
-- Name: COLUMN image_match.created_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.image_match.created_at IS 'NOTE THIS IS NOT THE IMAGE TIMESTAMP';


--
-- Name: line_accession; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.line_accession (
    line_accession character varying NOT NULL,
    species character varying NOT NULL,
    gene character varying,
    agi character varying
);


--
-- Name: plant; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plant (
    experiment_id character varying NOT NULL,
    line_accession character varying,
    local_id character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying,
    plant_id character varying NOT NULL,
    container_id character varying NOT NULL,
    containing_position integer NOT NULL,
    date_initialized date,
    date_final_transfer date,
    chamber_desc character varying,
    phenotype_desc character varying,
    treatment character varying,
    local_batch character varying
);


--
-- Name: plant_data; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plant_data (
    plant_id character varying NOT NULL,
    data_timestamp timestamp with time zone NOT NULL,
    height_cm numeric
);


--
-- Name: protocol; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.protocol (
    protocol_name character varying NOT NULL,
    protocol_url character varying
);


--
-- Name: protocol_match; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.protocol_match (
    protocol_name character varying NOT NULL,
    experiment_id character varying NOT NULL
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: scientist; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.scientist (
    scientist character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying
);


--
-- Name: section; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.section (
    section_name character varying NOT NULL,
    section_id character varying,
    section_location character varying
);


--
-- Name: TABLE section; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.section IS 'As in section of a greenhouse or section of a crop field';


--
-- Name: section_environment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.section_environment (
    section_name character varying NOT NULL,
    leach_ph numeric,
    leach_ec_ms_cm numeric,
    experiment_id character varying NOT NULL,
    environment_timestamp timestamp with time zone NOT NULL,
    emitter_volume_ml numeric,
    emitter_ph numeric,
    emitter_ec_ms_cm numeric,
    leach_volume_ml numeric
);


--
-- Name: species; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.species (
    species character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying
);


--
-- Name: column_reference column_reference_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.column_reference
    ADD CONSTRAINT column_reference_pkey PRIMARY KEY (column_table, column_name);


--
-- Name: container container_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.container
    ADD CONSTRAINT container_pkey PRIMARY KEY (container_id);


--
-- Name: plant containing_constraint; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plant
    ADD CONSTRAINT containing_constraint UNIQUE (container_id, containing_position);


--
-- Name: experiment experiment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT experiment_pkey PRIMARY KEY (experiment_id);


--
-- Name: greenhouse_box greenhouse_box_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greenhouse_box
    ADD CONSTRAINT greenhouse_box_pkey PRIMARY KEY (section_name, experiment_id);


--
-- Name: image_match image_match_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_match
    ADD CONSTRAINT image_match_pkey PRIMARY KEY (experiment_id, s3_key_raw);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (s3_key_raw);


--
-- Name: line_accession line_accession_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.line_accession
    ADD CONSTRAINT line_accession_pkey PRIMARY KEY (line_accession, species);


--
-- Name: plant_data plant_data_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plant_data
    ADD CONSTRAINT plant_data_pkey PRIMARY KEY (plant_id, data_timestamp);


--
-- Name: plant plant_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plant
    ADD CONSTRAINT plant_pkey PRIMARY KEY (plant_id);


--
-- Name: protocol_match protocol_match_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.protocol_match
    ADD CONSTRAINT protocol_match_pkey PRIMARY KEY (protocol_name, experiment_id);


--
-- Name: protocol protocol_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.protocol
    ADD CONSTRAINT protocol_pkey PRIMARY KEY (protocol_name);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: scientist scientist_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.scientist
    ADD CONSTRAINT scientist_pkey PRIMARY KEY (scientist);


--
-- Name: section_environment section_environment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.section_environment
    ADD CONSTRAINT section_environment_pkey PRIMARY KEY (experiment_id, section_name, environment_timestamp);


--
-- Name: section section_id_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT section_id_unique UNIQUE (section_id);


--
-- Name: section section_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT section_pkey PRIMARY KEY (section_name);


--
-- Name: species species_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.species
    ADD CONSTRAINT species_pkey PRIMARY KEY (species);


--
-- Name: image thumbnail_constraint; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT thumbnail_constraint UNIQUE (s3_key_thumbnail);


--
-- Name: fki_container_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_container_fkey ON public.plant USING btree (container_id);


--
-- Name: fki_experiment-foreign-key; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "fki_experiment-foreign-key" ON public.plant USING btree (experiment_id);


--
-- Name: fki_experiment_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_experiment_fkey ON public.container USING btree (experiment_id);


--
-- Name: fki_experiment_id_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_experiment_id_fkey ON public.section_environment USING btree (experiment_id);


--
-- Name: fki_plant_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_plant_fkey ON public.image_match USING btree (plant_id);


--
-- Name: fki_scientist_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_scientist_fkey ON public.experiment USING btree (scientist);


--
-- Name: fki_section_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_section_fkey ON public.greenhouse_box USING btree (section_name);


--
-- Name: fki_section_name_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_section_name_fkey ON public.section_environment USING btree (section_name);


--
-- Name: fki_species_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_species_fkey ON public.experiment USING btree (species);


--
-- Name: fki_species_ref_fkey; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX fki_species_ref_fkey ON public.line_accession USING btree (species);


--
-- Name: plant container_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plant
    ADD CONSTRAINT container_fkey FOREIGN KEY (container_id) REFERENCES public.container(container_id) NOT VALID;


--
-- Name: image_match container_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_match
    ADD CONSTRAINT container_fkey FOREIGN KEY (container_id) REFERENCES public.container(container_id);


--
-- Name: plant experiment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plant
    ADD CONSTRAINT experiment_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id) NOT VALID;


--
-- Name: container experiment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.container
    ADD CONSTRAINT experiment_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id) NOT VALID;


--
-- Name: greenhouse_box experiment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greenhouse_box
    ADD CONSTRAINT experiment_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id) NOT VALID;


--
-- Name: image_match experiment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_match
    ADD CONSTRAINT experiment_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id);


--
-- Name: protocol_match experiment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.protocol_match
    ADD CONSTRAINT experiment_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id) NOT VALID;


--
-- Name: section_environment experiment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.section_environment
    ADD CONSTRAINT experiment_id_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id) NOT VALID;


--
-- Name: image_match image_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_match
    ADD CONSTRAINT image_fkey FOREIGN KEY (s3_key_raw) REFERENCES public.image(s3_key_raw);


--
-- Name: image_match plant_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_match
    ADD CONSTRAINT plant_fkey FOREIGN KEY (plant_id) REFERENCES public.plant(plant_id) NOT VALID;


--
-- Name: experiment scientist_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT scientist_fkey FOREIGN KEY (scientist) REFERENCES public.scientist(scientist) NOT VALID;


--
-- Name: greenhouse_box section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.greenhouse_box
    ADD CONSTRAINT section_fkey FOREIGN KEY (section_name) REFERENCES public.section(section_name) NOT VALID;


--
-- Name: image_match section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.image_match
    ADD CONSTRAINT section_fkey FOREIGN KEY (section_name) REFERENCES public.section(section_name);


--
-- Name: section_environment section_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.section_environment
    ADD CONSTRAINT section_name_fkey FOREIGN KEY (section_name) REFERENCES public.section(section_name) NOT VALID;


--
-- Name: experiment species_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT species_fkey FOREIGN KEY (species) REFERENCES public.species(species) NOT VALID;


--
-- Name: line_accession species_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.line_accession
    ADD CONSTRAINT species_fkey FOREIGN KEY (species) REFERENCES public.species(species);


--
-- PostgreSQL database dump complete
--


--
-- Dbmate schema migrations
--

INSERT INTO public.schema_migrations (version) VALUES
    ('20210226020602'),
    ('20210301180245'),
    ('20210317181112'),
    ('20210320051505');
