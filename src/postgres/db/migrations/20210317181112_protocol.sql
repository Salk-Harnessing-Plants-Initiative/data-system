-- migrate:up
CREATE TABLE public.protocol
(
    protocol_name character varying NOT NULL,
    protocol_url character varying,
    PRIMARY KEY (protocol_name)
);

CREATE TABLE public.protocol_match
(
    protocol_name character varying NOT NULL,
    experiment_id character varying NOT NULL,
    PRIMARY KEY (protocol_name, experiment_id)
);

ALTER TABLE ONLY public.protocol_match
    ADD CONSTRAINT experiment_fkey FOREIGN KEY (experiment_id) REFERENCES public.experiment(experiment_id) NOT VALID;

-- migrate:down

