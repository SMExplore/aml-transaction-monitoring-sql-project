------ alerts table
CREATE TABLE public.alerts (
	alert_id varchar(12) DEFAULT (('ALT'::text || lpad(nextval('alert_seq'::regclass)::text, 6, '0'::text))) NOT NULL,
	rule_id varchar(10) NOT NULL,
	customer_id varchar(20) NOT NULL,
	alert_date date NOT NULL,
	alert_created timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	alert_status varchar(30) DEFAULT 'Open'::character varying NULL,
	assigned_to varchar(10) NULL,
	metric_value numeric(18, 4) NULL,
	CONSTRAINT alerts_pkey PRIMARY KEY (alert_id),
	CONSTRAINT chk_alert_dates CHECK ((alert_created >= alert_date)),
	CONSTRAINT chk_alert_status CHECK (((alert_status)::text = ANY ((ARRAY['Open'::character varying, 'Assigned'::character varying, 'Closed'::character varying, 'Converted to Case'::character varying, 'False Positive'::character varying])::text[]))),
	CONSTRAINT chk_metric_value CHECK ((metric_value >= (0)::numeric))
);


-- public.alerts foreign keys

ALTER TABLE public.alerts ADD CONSTRAINT fk_alert_customer FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);
ALTER TABLE public.alerts ADD CONSTRAINT fk_alert_investigator FOREIGN KEY (assigned_to) REFERENCES public.investigators(investigator_id);
ALTER TABLE public.alerts ADD CONSTRAINT fk_alert_rule FOREIGN KEY (rule_id) REFERENCES public.tm_rules(rule_id);

------ case_alerts table 
CREATE TABLE public.case_alerts (
	case_id varchar(12) NOT NULL,
	alert_id varchar(12) NOT NULL,
	CONSTRAINT case_alerts_pkey PRIMARY KEY (case_id, alert_id)
);


-- public.case_alerts foreign keys

ALTER TABLE public.case_alerts ADD CONSTRAINT fk_casealerts_alert FOREIGN KEY (alert_id) REFERENCES public.alerts(alert_id);
ALTER TABLE public.case_alerts ADD CONSTRAINT fk_casealerts_case FOREIGN KEY (case_id) REFERENCES public.cases(case_id);

-- public.case_notes definition

-- Drop table

-- DROP TABLE public.case_notes;

CREATE TABLE public.case_notes (
	note_id serial4 NOT NULL,
	case_id varchar(12) NOT NULL,
	note_timestamp timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	investigator_notes text NULL,
	CONSTRAINT case_notes_pkey PRIMARY KEY (note_id)
);


-- public.case_notes foreign keys

ALTER TABLE public.case_notes ADD CONSTRAINT fk_notes_case FOREIGN KEY (case_id) REFERENCES public.cases(case_id);

-- public.cases definition

-- Drop table

-- DROP TABLE public.cases;

CREATE TABLE public.cases (
	case_id varchar(12) DEFAULT (('CASE'::text || lpad(nextval('case_seq'::regclass)::text, 6, '0'::text))) NOT NULL,
	customer_id varchar(20) NOT NULL,
	case_created timestamp DEFAULT CURRENT_TIMESTAMP NULL,
	case_status varchar(30) DEFAULT 'Open'::character varying NULL,
	disposition varchar(100) NULL,
	investigator varchar(10) NULL,
	CONSTRAINT cases_pkey PRIMARY KEY (case_id),
	CONSTRAINT chk_case_disposition CHECK (((disposition IS NULL) OR ((disposition)::text = ANY ((ARRAY['No Suspicion'::character varying, 'Monitoring Continued'::character varying, 'SAR Recommended'::character varying])::text[])))),
	CONSTRAINT chk_case_status CHECK (((case_status)::text = ANY ((ARRAY['Open'::character varying, 'Under Investigation'::character varying, 'Closed'::character varying])::text[])))
);


-- public.cases foreign keys

ALTER TABLE public.cases ADD CONSTRAINT fk_case_customer FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);
ALTER TABLE public.cases ADD CONSTRAINT fk_case_investigator FOREIGN KEY (investigator) REFERENCES public.investigators(investigator_id);

-- public.customers definition

-- Drop table

-- DROP TABLE public.customers;

CREATE TABLE public.customers (
	customer_id varchar(50) NOT NULL,
	customer_type varchar(50) NULL,
	customer_name varchar(50) NULL,
	country varchar(50) NULL,
	city varchar(50) NULL,
	customer_since date NULL,
	risk_rating varchar(50) NULL,
	occupation varchar(50) NULL,
	industry varchar(50) NULL,
	annual_income numeric NULL,
	expected_monthly_volume numeric NULL,
	expected_transaction_count int4 NULL,
	pep_flag varchar(50) NULL,
	sanctions_flag varchar(50) NULL,
	CONSTRAINT customers_pkey PRIMARY KEY (customer_id)
);

-- public.investigators definition

-- Drop table

-- DROP TABLE public.investigators;

CREATE TABLE public.investigators (
	investigator_id varchar(10) NOT NULL,
	investigator_name varchar(100) NULL,
	team varchar(50) NULL,
	status varchar(20) NULL,
	CONSTRAINT chk_investigator_status CHECK (((status)::text = ANY ((ARRAY['Active'::character varying, 'Inactive'::character varying])::text[]))),
	CONSTRAINT investigators_pkey PRIMARY KEY (investigator_id)
);

-- public.tm_rules definition

-- Drop table

-- DROP TABLE public.tm_rules;

CREATE TABLE public.tm_rules (
	rule_id varchar(10) NOT NULL,
	rule_name varchar(100) NULL,
	risk_score int4 NULL,
	is_active bool NULL,
	rule_description text NULL,
	typology varchar(100) NULL,
	priority varchar(20) NULL,
	CONSTRAINT chk_tm_rules_priority CHECK (((priority)::text = ANY ((ARRAY['Low'::character varying, 'Medium'::character varying, 'High'::character varying, 'Critical'::character varying])::text[]))),
	CONSTRAINT tm_rules_pkey PRIMARY KEY (rule_id)
);

-- public.transactions definition

-- Drop table

-- DROP TABLE public.transactions;

CREATE TABLE public.transactions (
	txn_id varchar(50) NOT NULL,
	customer_id varchar(50) NULL,
	counterparty_id varchar(50) NULL,
	transaction_datetime timestamp NULL,
	amount numeric NULL,
	currency varchar(50) NULL,
	transaction_type varchar(50) NULL,
	direction varchar(50) NULL,
	channel varchar(50) NULL,
	country_origin varchar(50) NULL,
	country_destination varchar(50) NULL,
	balance_before numeric NULL,
	balance_after numeric NULL,
	merchant_category varchar(50) NULL,
	device_id varchar(50) NULL,
	branch_id varchar(50) NULL,
	CONSTRAINT transactions_pkey PRIMARY KEY (txn_id)
);
CREATE INDEX idx_txn_customer ON public.transactions USING btree (customer_id);
CREATE INDEX idx_txn_datetime ON public.transactions USING btree (transaction_datetime);
CREATE INDEX idx_txn_type ON public.transactions USING btree (transaction_type);


-- public.transactions foreign keys

ALTER TABLE public.transactions ADD CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES public.customers(customer_id);