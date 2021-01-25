--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4
-- Dumped by pg_dump version 13.0

-- Started on 2021-01-24 23:07:19 PST

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
-- TOC entry 204 (class 1259 OID 16441)
-- Name: container; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.container (
    container_type character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying,
    experiment_id character varying NOT NULL,
    container_id character varying NOT NULL
);


ALTER TABLE public.container OWNER TO postgres;

--
-- TOC entry 203 (class 1259 OID 16417)
-- Name: experiment; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.experiment OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 16700)
-- Name: greenhouse_box; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.greenhouse_box (
    section_name character varying NOT NULL,
    experiment_id character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying
);


ALTER TABLE public.greenhouse_box OWNER TO postgres;

--
-- TOC entry 3919 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE greenhouse_box; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.greenhouse_box IS 'Mappings to greenhouse Box folders';


--
-- TOC entry 207 (class 1259 OID 16548)
-- Name: image; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.image (
    s3_key_raw character varying NOT NULL,
    s3_key_thumbnail character varying,
    created_by character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_input_filename character varying NOT NULL,
    image_timestamp timestamp with time zone,
    qr_code character varying,
    upload_device_id character varying,
    qr_codes character varying
);


ALTER TABLE public.image OWNER TO postgres;

--
-- TOC entry 3921 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN image.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.image.created_at IS 'Pay special attention to the fact that this refers to the time at which this entry was created in the database, NOT the file creation time';


--
-- TOC entry 3922 (class 0 OID 0)
-- Dependencies: 207
-- Name: COLUMN image.qr_codes; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.image.qr_codes IS 'List of all QR codes present in the image (optional use for the crazy case where multiple have been detected). Formatted as a stringified list. E.g. ["apple", "banana"]';


--
-- TOC entry 211 (class 1259 OID 16841)
-- Name: image_match; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.image_match (
    s3_key_raw character varying NOT NULL,
    experiment_id character varying NOT NULL,
    container_id character varying,
    section_name character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.image_match OWNER TO postgres;

--
-- TOC entry 3924 (class 0 OID 0)
-- Dependencies: 211
-- Name: COLUMN image_match.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.image_match.created_at IS 'NOTE THIS IS NOT THE IMAGE TIMESTAMP';


--
-- TOC entry 202 (class 1259 OID 16401)
-- Name: plant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.plant (
    experiment_id character varying NOT NULL,
    line_accession character varying,
    local_id character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying,
    plant_id character varying NOT NULL,
    container_id character varying NOT NULL,
    containing_position integer NOT NULL
);


ALTER TABLE public.plant OWNER TO postgres;

--
-- TOC entry 206 (class 1259 OID 16513)
-- Name: scientist; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.scientist (
    scientist character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying
);


ALTER TABLE public.scientist OWNER TO postgres;

--
-- TOC entry 209 (class 1259 OID 16750)
-- Name: section; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.section (
    section_name character varying NOT NULL,
    section_id character varying,
    section_location character varying
);


ALTER TABLE public.section OWNER TO postgres;

--
-- TOC entry 3928 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE section; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.section IS 'As in section of a greenhouse or section of a crop field';


--
-- TOC entry 210 (class 1259 OID 16812)
-- Name: section_environment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.section_environment (
    section_name character varying NOT NULL,
    leach_ph numeric,
    leach_ec_ms_cm numeric,
    experiment_id character varying NOT NULL,
    environment_timestamp timestamp with time zone DEFAULT now() NOT NULL,
    emitter_volume_ml numeric,
    emitter_ph numeric,
    emitter_ec_ms_cm numeric,
    leach_volume_ml numeric
);


ALTER TABLE public.section_environment OWNER TO postgres;

--
-- TOC entry 205 (class 1259 OID 16504)
-- Name: species; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.species (
    species character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by character varying
);


ALTER TABLE public.species OWNER TO postgres;

--
-- TOC entry 3749 (class 2606 OID 16642)
-- Name: container container_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.container
    ADD CONSTRAINT container_pkey PRIMARY KEY (container_id);


--
-- TOC entry 3737 (class 2606 OID 16646)
-- Name: plant containing_constraint; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plant
    ADD CONSTRAINT containing_constraint UNIQUE (container_id, containing_position);


--
-- TOC entry 3745 (class 2606 OID 16424)
-- Name: experiment experiment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT experiment_pkey PRIMARY KEY (experiment_id);


--
-- TOC entry 3761 (class 2606 OID 16707)
-- Name: greenhouse_box greenhouse_box_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.greenhouse_box
    ADD CONSTRAINT greenhouse_box_pkey PRIMARY KEY (section_name, experiment_id);


--
-- TOC entry 3771 (class 2606 OID 16848)
-- Name: image_match image_match_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_match
    ADD CONSTRAINT image_match_pkey PRIMARY KEY (experiment_id, s3_key_raw);


--
-- TOC entry 3756 (class 2606 OID 16555)
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (s3_key_raw);


--
-- TOC entry 3741 (class 2606 OID 16473)
-- Name: plant local_id_constraint; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plant
    ADD CONSTRAINT local_id_constraint UNIQUE (experiment_id, local_id);


--
-- TOC entry 3743 (class 2606 OID 16644)
-- Name: plant plant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plant
    ADD CONSTRAINT plant_pkey PRIMARY KEY (plant_id);


--
-- TOC entry 3754 (class 2606 OID 16520)
-- Name: scientist scientist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scientist
    ADD CONSTRAINT scientist_pkey PRIMARY KEY (scientist);


--
-- TOC entry 3769 (class 2606 OID 16819)
-- Name: section_environment section_environment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.section_environment
    ADD CONSTRAINT section_environment_pkey PRIMARY KEY (experiment_id, section_name, environment_timestamp);


--
-- TOC entry 3763 (class 2606 OID 16759)
-- Name: section section_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT section_id_unique UNIQUE (section_id);


--
-- TOC entry 3765 (class 2606 OID 16757)
-- Name: section section_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT section_pkey PRIMARY KEY (section_name);


--
-- TOC entry 3752 (class 2606 OID 16511)
-- Name: species species_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.species
    ADD CONSTRAINT species_pkey PRIMARY KEY (species);


--
-- TOC entry 3758 (class 2606 OID 16840)
-- Name: image thumbnail_constraint; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT thumbnail_constraint UNIQUE (s3_key_thumbnail);


--
-- TOC entry 3738 (class 1259 OID 16652)
-- Name: fki_container_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_container_fkey ON public.plant USING btree (container_id);


--
-- TOC entry 3739 (class 1259 OID 16435)
-- Name: fki_experiment-foreign-key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_experiment-foreign-key" ON public.plant USING btree (experiment_id);


--
-- TOC entry 3750 (class 1259 OID 16543)
-- Name: fki_experiment_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_experiment_fkey ON public.container USING btree (experiment_id);


--
-- TOC entry 3766 (class 1259 OID 16831)
-- Name: fki_experiment_id_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_experiment_id_fkey ON public.section_environment USING btree (experiment_id);


--
-- TOC entry 3746 (class 1259 OID 16534)
-- Name: fki_scientist_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_scientist_fkey ON public.experiment USING btree (scientist);


--
-- TOC entry 3759 (class 1259 OID 16736)
-- Name: fki_section_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_section_fkey ON public.greenhouse_box USING btree (section_name);


--
-- TOC entry 3767 (class 1259 OID 16825)
-- Name: fki_section_name_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_section_name_fkey ON public.section_environment USING btree (section_name);


--
-- TOC entry 3747 (class 1259 OID 16528)
-- Name: fki_species_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_species_fkey ON public.experiment USING btree (species);


--
-- TOC entry 3773 (class 2606 OID 16647)
-- Name: plant container_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plant
    ADD CONSTRAINT container_fkey FOREIGN KEY (container_id) REFERENCES public.container(container_id) NOT VALID;


--
-- TOC entry 3783 (class 2606 OID 16859)
-- Name: image_match container_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_match
    ADD CONSTRAINT container_fkey FOREIGN KEY (container_id) REFERENCES public.container(container_id);


--
-- TOC entry 3772 (class 2606 OID 16436)
-- Name: plant experiment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plant
    ADD CONSTRAINT experiment_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id) NOT VALID;


--
-- TOC entry 3776 (class 2606 OID 16538)
-- Name: container experiment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.container
    ADD CONSTRAINT experiment_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id) NOT VALID;


--
-- TOC entry 3777 (class 2606 OID 16745)
-- Name: greenhouse_box experiment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.greenhouse_box
    ADD CONSTRAINT experiment_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id) NOT VALID;


--
-- TOC entry 3782 (class 2606 OID 16854)
-- Name: image_match experiment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_match
    ADD CONSTRAINT experiment_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id);


--
-- TOC entry 3780 (class 2606 OID 16826)
-- Name: section_environment experiment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.section_environment
    ADD CONSTRAINT experiment_id_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id) NOT VALID;


--
-- TOC entry 3781 (class 2606 OID 16849)
-- Name: image_match image_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_match
    ADD CONSTRAINT image_fkey FOREIGN KEY (s3_key_raw) REFERENCES public.image(s3_key_raw);


--
-- TOC entry 3775 (class 2606 OID 16529)
-- Name: experiment scientist_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT scientist_fkey FOREIGN KEY (scientist) REFERENCES public.scientist(scientist) NOT VALID;


--
-- TOC entry 3778 (class 2606 OID 16760)
-- Name: greenhouse_box section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.greenhouse_box
    ADD CONSTRAINT section_fkey FOREIGN KEY (section_name) REFERENCES public.section(section_name) NOT VALID;


--
-- TOC entry 3784 (class 2606 OID 16864)
-- Name: image_match section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_match
    ADD CONSTRAINT section_fkey FOREIGN KEY (section_name) REFERENCES public.section(section_name);


--
-- TOC entry 3779 (class 2606 OID 16820)
-- Name: section_environment section_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.section_environment
    ADD CONSTRAINT section_name_fkey FOREIGN KEY (section_name) REFERENCES public.section(section_name) NOT VALID;


--
-- TOC entry 3774 (class 2606 OID 16523)
-- Name: experiment species_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT species_fkey FOREIGN KEY (species) REFERENCES public.species(species) NOT VALID;


--
-- TOC entry 3916 (class 0 OID 0)
-- Dependencies: 3
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM rdsadmin;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;
GRANT USAGE ON SCHEMA public TO readaccess;


--
-- TOC entry 3917 (class 0 OID 0)
-- Dependencies: 204
-- Name: TABLE container; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.container TO readaccess;


--
-- TOC entry 3918 (class 0 OID 0)
-- Dependencies: 203
-- Name: TABLE experiment; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.experiment TO readaccess;


--
-- TOC entry 3920 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE greenhouse_box; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.greenhouse_box TO readaccess;


--
-- TOC entry 3923 (class 0 OID 0)
-- Dependencies: 207
-- Name: TABLE image; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.image TO readaccess;


--
-- TOC entry 3925 (class 0 OID 0)
-- Dependencies: 211
-- Name: TABLE image_match; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.image_match TO readaccess;


--
-- TOC entry 3926 (class 0 OID 0)
-- Dependencies: 202
-- Name: TABLE plant; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.plant TO readaccess;


--
-- TOC entry 3927 (class 0 OID 0)
-- Dependencies: 206
-- Name: TABLE scientist; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.scientist TO readaccess;


--
-- TOC entry 3929 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE section; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.section TO readaccess;


--
-- TOC entry 3930 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE section_environment; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.section_environment TO readaccess;


--
-- TOC entry 3931 (class 0 OID 0)
-- Dependencies: 205
-- Name: TABLE species; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.species TO readaccess;


--
-- TOC entry 1733 (class 826 OID 16780)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT SELECT ON TABLES  TO readaccess;


-- Completed on 2021-01-24 23:07:24 PST

--
-- PostgreSQL database dump complete
--

