--
-- PostgreSQL database dump
--

-- Dumped from database version 12.4
-- Dumped by pg_dump version 13.0

-- Started on 2021-01-15 01:12:49 PST

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
    created_by character varying
);


ALTER TABLE public.experiment OWNER TO postgres;

--
-- TOC entry 208 (class 1259 OID 16700)
-- Name: greenhouse_box; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.greenhouse_box (
    section_name character varying NOT NULL,
    experiment_id character varying NOT NULL,
    box_folder_id character varying
);


ALTER TABLE public.greenhouse_box OWNER TO postgres;

--
-- TOC entry 3901 (class 0 OID 0)
-- Dependencies: 208
-- Name: TABLE greenhouse_box; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.greenhouse_box IS 'Mappings to greenhouse Box folders';


--
-- TOC entry 209 (class 1259 OID 16708)
-- Name: greenhouse_giraffe; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.greenhouse_giraffe (
    experiment_id character varying NOT NULL,
    section_id character varying NOT NULL,
    cluster_timestamp timestamp with time zone NOT NULL,
    key_template character varying NOT NULL
);


ALTER TABLE public.greenhouse_giraffe OWNER TO postgres;

--
-- TOC entry 3902 (class 0 OID 0)
-- Dependencies: 209
-- Name: TABLE greenhouse_giraffe; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.greenhouse_giraffe IS 'Mappings of where to find contiguous top-down images of greenhouse plants in AWS S3. You take the key_template and all the contiguous photos are in 1-indexed ascending order. E.g. "images/raw/NVJsjnc/beautiful_morning" means the look in NVJsinc for "beautiful_morning_1.png", "beautiful_morning_2.png", etc. Time is the timestamp of the first image in the cluster.';


--
-- TOC entry 207 (class 1259 OID 16548)
-- Name: image; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.image (
    raw character varying NOT NULL,
    thumbnail character varying,
    created_by character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_input_filename character varying NOT NULL,
    container_id character varying
);


ALTER TABLE public.image OWNER TO postgres;

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
-- TOC entry 210 (class 1259 OID 16750)
-- Name: section; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.section (
    section_name character varying NOT NULL,
    section_id character varying,
    section_location character varying
);


ALTER TABLE public.section OWNER TO postgres;

--
-- TOC entry 3903 (class 0 OID 0)
-- Dependencies: 210
-- Name: TABLE section; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.section IS 'As in section of a greenhouse or section of a crop field';


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
-- TOC entry 3740 (class 2606 OID 16642)
-- Name: container container_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.container
    ADD CONSTRAINT container_pkey PRIMARY KEY (container_id);


--
-- TOC entry 3728 (class 2606 OID 16646)
-- Name: plant containing_constraint; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plant
    ADD CONSTRAINT containing_constraint UNIQUE (container_id, containing_position);


--
-- TOC entry 3736 (class 2606 OID 16424)
-- Name: experiment experiment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT experiment_pkey PRIMARY KEY (experiment_id);


--
-- TOC entry 3750 (class 2606 OID 16707)
-- Name: greenhouse_box greenhouse_box_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.greenhouse_box
    ADD CONSTRAINT greenhouse_box_pkey PRIMARY KEY (section_name, experiment_id);


--
-- TOC entry 3754 (class 2606 OID 16715)
-- Name: greenhouse_giraffe greenhouse_giraffe_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.greenhouse_giraffe
    ADD CONSTRAINT greenhouse_giraffe_pkey PRIMARY KEY (experiment_id, section_id, cluster_timestamp);


--
-- TOC entry 3747 (class 2606 OID 16555)
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (raw);


--
-- TOC entry 3756 (class 2606 OID 16717)
-- Name: greenhouse_giraffe key_template_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.greenhouse_giraffe
    ADD CONSTRAINT key_template_unique UNIQUE (key_template);


--
-- TOC entry 3732 (class 2606 OID 16473)
-- Name: plant local_id_constraint; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plant
    ADD CONSTRAINT local_id_constraint UNIQUE (experiment_id, local_id);


--
-- TOC entry 3734 (class 2606 OID 16644)
-- Name: plant plant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plant
    ADD CONSTRAINT plant_pkey PRIMARY KEY (plant_id);


--
-- TOC entry 3745 (class 2606 OID 16520)
-- Name: scientist scientist_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.scientist
    ADD CONSTRAINT scientist_pkey PRIMARY KEY (scientist);


--
-- TOC entry 3758 (class 2606 OID 16759)
-- Name: section section_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT section_id_unique UNIQUE (section_id);


--
-- TOC entry 3752 (class 2606 OID 16778)
-- Name: greenhouse_box section_name_box_folder_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.greenhouse_box
    ADD CONSTRAINT section_name_box_folder_unique UNIQUE (section_name, box_folder_id);


--
-- TOC entry 3760 (class 2606 OID 16757)
-- Name: section section_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT section_pkey PRIMARY KEY (section_name);


--
-- TOC entry 3743 (class 2606 OID 16511)
-- Name: species species_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.species
    ADD CONSTRAINT species_pkey PRIMARY KEY (species);


--
-- TOC entry 3729 (class 1259 OID 16652)
-- Name: fki_container_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_container_fkey ON public.plant USING btree (container_id);


--
-- TOC entry 3730 (class 1259 OID 16435)
-- Name: fki_experiment-foreign-key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "fki_experiment-foreign-key" ON public.plant USING btree (experiment_id);


--
-- TOC entry 3741 (class 1259 OID 16543)
-- Name: fki_experiment_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_experiment_fkey ON public.container USING btree (experiment_id);


--
-- TOC entry 3737 (class 1259 OID 16534)
-- Name: fki_scientist_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_scientist_fkey ON public.experiment USING btree (scientist);


--
-- TOC entry 3748 (class 1259 OID 16736)
-- Name: fki_section_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_section_fkey ON public.greenhouse_box USING btree (section_name);


--
-- TOC entry 3738 (class 1259 OID 16528)
-- Name: fki_species_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX fki_species_fkey ON public.experiment USING btree (species);


--
-- TOC entry 3762 (class 2606 OID 16647)
-- Name: plant container_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plant
    ADD CONSTRAINT container_fkey FOREIGN KEY (container_id) REFERENCES public.container(container_id) NOT VALID;


--
-- TOC entry 3761 (class 2606 OID 16436)
-- Name: plant experiment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.plant
    ADD CONSTRAINT experiment_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id) NOT VALID;


--
-- TOC entry 3765 (class 2606 OID 16538)
-- Name: container experiment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.container
    ADD CONSTRAINT experiment_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id) NOT VALID;


--
-- TOC entry 3766 (class 2606 OID 16745)
-- Name: greenhouse_box experiment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.greenhouse_box
    ADD CONSTRAINT experiment_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id) NOT VALID;


--
-- TOC entry 3768 (class 2606 OID 16718)
-- Name: greenhouse_giraffe experiment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.greenhouse_giraffe
    ADD CONSTRAINT experiment_id_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id);


--
-- TOC entry 3764 (class 2606 OID 16529)
-- Name: experiment scientist_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT scientist_fkey FOREIGN KEY (scientist) REFERENCES public.scientist(scientist) NOT VALID;


--
-- TOC entry 3767 (class 2606 OID 16760)
-- Name: greenhouse_box section_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.greenhouse_box
    ADD CONSTRAINT section_fkey FOREIGN KEY (section_name) REFERENCES public.section(section_name) NOT VALID;


--
-- TOC entry 3763 (class 2606 OID 16523)
-- Name: experiment species_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiment
    ADD CONSTRAINT species_fkey FOREIGN KEY (species) REFERENCES public.species(species) NOT VALID;


--
-- TOC entry 3900 (class 0 OID 0)
-- Dependencies: 3
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM rdsadmin;
REVOKE ALL ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2021-01-15 01:12:54 PST

--
-- PostgreSQL database dump complete
--

