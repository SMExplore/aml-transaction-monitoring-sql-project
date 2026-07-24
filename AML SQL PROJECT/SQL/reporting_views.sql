-- public.vw_dashboard_alerts source

CREATE OR REPLACE VIEW public.vw_dashboard_alerts
AS SELECT a.alert_id,
    a.alert_date,
    a.alert_created,
    a.alert_status,
    a.assigned_to,
    i.investigator_name,
    a.customer_id,
    c.customer_type,
    c.country,
    c.risk_rating,
    c.annual_income,
    a.rule_id,
    tm.rule_name,
    tm.typology,
    tm.priority,
    tm.risk_score,
    a.metric_value
   FROM alerts a
     LEFT JOIN investigators i ON a.assigned_to::text = i.investigator_id::text
     JOIN customers c ON c.customer_id::text = a.customer_id::text
     JOIN tm_rules tm ON a.rule_id::text = tm.rule_id::text;
	 
-- public.vw_dashboard_cases source

CREATE OR REPLACE VIEW public.vw_dashboard_cases
AS WITH tmu AS (
         SELECT tr.rule_id,
            tr.rule_name,
            tr.risk_score,
            tr.is_active,
            tr.rule_description,
            tr.typology,
            tr.priority,
                CASE
                    WHEN tr.priority::text = 'Medium'::text THEN '1'::text
                    WHEN tr.priority::text = 'High'::text THEN '2'::text
                    WHEN tr.priority::text = 'Critical'::text THEN '3'::text
                    ELSE NULL::text
                END AS priority_numeric
           FROM tm_rules tr
        )
 SELECT c.case_id,
    c.customer_id,
    c.investigator,
    i.investigator_name,
    c.case_created,
    c.case_status,
    c.disposition,
    count(ca.alert_id) AS alert_count,
    string_agg(DISTINCT tm.rule_name::text, ','::text ORDER BY (tm.rule_name::text)) AS rules_triggered,
    max(cn.note_timestamp) AS latest_note,
    max(cn.investigator_notes) AS investigation_notes,
    max(tm.priority_numeric) AS priority_numeric
   FROM cases c
     LEFT JOIN investigators i ON c.investigator::text = i.investigator_id::text
     LEFT JOIN case_alerts ca ON c.case_id::text = ca.case_id::text
     LEFT JOIN alerts a ON ca.alert_id::text = a.alert_id::text
     LEFT JOIN tmu tm ON a.rule_id::text = tm.rule_id::text
     LEFT JOIN case_notes cn ON c.case_id::text = cn.case_id::text
  GROUP BY c.case_id, c.customer_id, c.investigator, c.case_created, c.case_status, c.disposition, i.investigator_name
  ORDER BY c.case_id;
  
-- public.vw_dashboard_customer source

CREATE OR REPLACE VIEW public.vw_dashboard_customer
AS SELECT c.customer_id,
    c.customer_type,
    c.country,
    c.risk_rating,
    c.annual_income,
    c.expected_monthly_volume,
    count(DISTINCT a.alert_id) AS total_alerts,
    count(DISTINCT cs.case_id) AS total_cases,
    max(a.alert_date) AS latest_alert,
    max(cs.case_created) AS latest_case
   FROM customers c
     LEFT JOIN alerts a ON c.customer_id::text = a.customer_id::text
     LEFT JOIN cases cs ON c.customer_id::text = cs.customer_id::text
  GROUP BY c.customer_id, c.customer_type, c.country, c.risk_rating, c.annual_income, c.expected_monthly_volume;
  
-- public.vw_alert_rate_by_risk source

CREATE OR REPLACE VIEW public.vw_alert_rate_by_risk
AS WITH sl AS (
         SELECT count(DISTINCT a.alert_id) AS alerts,
            c_1.risk_rating
           FROM alerts a
             LEFT JOIN customers c_1 ON a.customer_id::text = c_1.customer_id::text
          GROUP BY c_1.risk_rating
        )
 SELECT s.risk_rating,
    count(DISTINCT c.customer_id) AS customers,
    s.alerts,
    round(s.alerts::numeric / count(DISTINCT c.customer_id)::numeric, 2) AS alerts_per_customer
   FROM customers c
     JOIN sl s ON c.risk_rating::text = s.risk_rating::text
  GROUP BY s.risk_rating, s.alerts;