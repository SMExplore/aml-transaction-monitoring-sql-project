-- public.vw_rule_001_dormant source

CREATE OR REPLACE VIEW public.vw_rule_001_dormant
AS WITH shortlist_cust AS (
         SELECT sub1.customer_id,
            sub1.transaction_datetime,
            sub1.last_trx_dt,
            sub1.transaction_datetime - sub1.last_trx_dt AS time_since_lst_trx
           FROM ( SELECT transactions.customer_id,
                    transactions.transaction_datetime,
                    lag(transactions.transaction_datetime, 1) OVER (PARTITION BY transactions.customer_id ORDER BY transactions.transaction_datetime) AS last_trx_dt
                   FROM transactions) sub1
          WHERE sub1.last_trx_dt IS NOT NULL AND (sub1.transaction_datetime - sub1.last_trx_dt) > '180 days'::interval
          ORDER BY (sub1.transaction_datetime - sub1.last_trx_dt) DESC
        )
 SELECT 'R001'::text AS rule_id,
    t.customer_id,
    sc.transaction_datetime AS alert_date,
    sum(t.amount) AS volume,
    count(t.amount) AS trx_count,
    c.customer_type,
    c.country,
    c.risk_rating,
    c.annual_income,
    c.expected_transaction_count,
    c.expected_monthly_volume,
    sum(t.amount) / c.expected_monthly_volume AS volume_multiple,
    sc.transaction_datetime - sc.last_trx_dt AS delay
   FROM transactions t
     RIGHT JOIN shortlist_cust sc ON t.customer_id::text = sc.customer_id::text
     JOIN customers c ON t.customer_id::text = c.customer_id::text
  WHERE t.transaction_datetime < (sc.transaction_datetime + '30 days'::interval) AND t.transaction_datetime >= sc.transaction_datetime
  GROUP BY 'R001'::text, t.customer_id, sc.transaction_datetime, c.customer_type, c.country, c.risk_rating, c.annual_income, c.expected_transaction_count, c.expected_monthly_volume, (sc.transaction_datetime - sc.last_trx_dt)
 HAVING sum(t.amount) > (2::numeric * c.expected_monthly_volume) OR (sc.transaction_datetime - sc.last_trx_dt) > '300 days'::interval
  ORDER BY 'R001'::text, t.customer_id DESC;
  
-- public.vw_rule_002_structuring source

CREATE OR REPLACE VIEW public.vw_rule_002_structuring
AS WITH suspicious_days AS (
         SELECT t.customer_id,
            t.transaction_datetime::date AS transaction_date,
            sum(t.amount) AS deposit_volume,
            count(*) AS deposit_count
           FROM transactions t
          WHERE t.transaction_type::text = 'CASH_DEPOSIT'::text
          GROUP BY t.customer_id, (t.transaction_datetime::date)
         HAVING count(*) >= 2
        ), customer_summary AS (
         SELECT suspicious_days.customer_id,
            count(*) AS suspicious_days,
            max(suspicious_days.transaction_date) AS alert_date
           FROM suspicious_days
          GROUP BY suspicious_days.customer_id
        )
 SELECT 'R002'::text AS rule_id,
    cs.customer_id,
    cs.alert_date,
    cs.suspicious_days,
    sd.deposit_count,
    sd.deposit_volume,
    c.customer_type,
    c.country,
    c.risk_rating,
    c.annual_income,
    c.expected_monthly_volume
   FROM customer_summary cs
     JOIN suspicious_days sd ON cs.customer_id::text = sd.customer_id::text AND cs.alert_date = sd.transaction_date
     JOIN customers c ON cs.customer_id::text = c.customer_id::text
  ORDER BY cs.suspicious_days DESC, cs.customer_id;
  
-- public.vw_rule_003_funnel source

CREATE OR REPLACE VIEW public.vw_rule_003_funnel
AS WITH high_incoming AS (
         SELECT c_1.customer_id,
            count(DISTINCT t_1.counterparty_id) AS in_unq_ctrparty,
            sum(t_1.amount) AS in_total_volume,
            count(*) AS in_trx_no
           FROM customers c_1
             JOIN transactions t_1 ON c_1.customer_id::text = t_1.customer_id::text
          WHERE t_1.direction::text = 'IN'::text
          GROUP BY c_1.customer_id
         HAVING count(DISTINCT t_1.counterparty_id) >= 10 AND sum(t_1.amount) > (5::numeric * c_1.annual_income)
        ), customer_activity AS (
         SELECT transactions.customer_id,
            max(transactions.transaction_datetime)::date AS alert_date
           FROM transactions
          GROUP BY transactions.customer_id
        )
 SELECT 'R003'::text AS rule_id,
    h.customer_id,
    ca.alert_date,
    h.in_unq_ctrparty,
    h.in_total_volume,
    h.in_trx_no,
    sum(t.amount) AS out_total_volume,
    count(DISTINCT t.counterparty_id) AS out_unq_ctrparty,
    c.country,
    c.customer_type,
    c.annual_income,
    c.risk_rating,
    sum(t.amount) / h.in_total_volume AS pass_through_ratio
   FROM high_incoming h
     JOIN transactions t ON t.customer_id::text = h.customer_id::text
     JOIN customers c ON h.customer_id::text = c.customer_id::text
     JOIN customer_activity ca ON h.customer_id::text = ca.customer_id::text
  WHERE t.direction::text = 'OUT'::text
  GROUP BY 'R003'::text, h.customer_id, ca.alert_date, h.in_unq_ctrparty, h.in_total_volume, h.in_trx_no, c.country, c.customer_type, c.annual_income, c.risk_rating
 HAVING h.in_total_volume > sum(t.amount) AND sum(t.amount) > (0.80 * h.in_total_volume)
  ORDER BY h.in_unq_ctrparty DESC;
  
-- public.vw_rule_004_velocity source

CREATE OR REPLACE VIEW public.vw_rule_004_velocity
AS WITH monthly_counts AS (
         SELECT x.customer_id,
            x.txn_month,
            x.monthly_txn_count,
            avg(x.monthly_txn_count) OVER (PARTITION BY x.customer_id) AS avg_monthly_count
           FROM ( SELECT transactions.customer_id,
                    date_trunc('month'::text, transactions.transaction_datetime) AS txn_month,
                    count(*) AS monthly_txn_count
                   FROM transactions
                  GROUP BY transactions.customer_id, (date_trunc('month'::text, transactions.transaction_datetime))) x
        )
 SELECT 'R004'::text AS rule_id,
    mc.customer_id,
    mc.txn_month AS alert_date,
    mc.avg_monthly_count,
    mc.monthly_txn_count::numeric / NULLIF(mc.avg_monthly_count, 0::numeric) AS spike_multiple,
    c.risk_rating,
    c.expected_transaction_count,
    c.customer_type,
    c.country
   FROM monthly_counts mc
     JOIN customers c ON mc.customer_id::text = c.customer_id::text
  WHERE mc.monthly_txn_count >= 15 AND (mc.monthly_txn_count::numeric / NULLIF(mc.avg_monthly_count, 0::numeric)) >= 1.5
  ORDER BY (mc.monthly_txn_count::numeric / NULLIF(mc.avg_monthly_count, 0::numeric)) DESC;
  
-- public.vw_rule_005_rapid_movement source

CREATE OR REPLACE VIEW public.vw_rule_005_rapid_movement
AS WITH daily_flows AS (
         SELECT transactions.customer_id,
            transactions.transaction_datetime::date AS alert_date,
            sum(
                CASE
                    WHEN transactions.direction::text = 'IN'::text THEN transactions.amount
                    ELSE 0::numeric
                END) AS incoming_volume,
            sum(
                CASE
                    WHEN transactions.direction::text = 'OUT'::text THEN transactions.amount
                    ELSE 0::numeric
                END) AS outgoing_volume,
            count(
                CASE
                    WHEN transactions.direction::text = 'IN'::text THEN 1
                    ELSE NULL::integer
                END) AS incoming_txns,
            count(
                CASE
                    WHEN transactions.direction::text = 'OUT'::text THEN 1
                    ELSE NULL::integer
                END) AS outgoing_txns
           FROM transactions
          GROUP BY transactions.customer_id, (transactions.transaction_datetime::date)
        ), scored AS (
         SELECT daily_flows.customer_id,
            daily_flows.alert_date,
            daily_flows.incoming_volume,
            daily_flows.outgoing_volume,
            daily_flows.incoming_txns,
            daily_flows.outgoing_txns,
            daily_flows.outgoing_volume / NULLIF(daily_flows.incoming_volume, 0::numeric) AS pass_through_ratio
           FROM daily_flows
        )
 SELECT 'R005'::text AS rule_id,
    s.customer_id,
    s.alert_date,
    s.incoming_volume,
    s.outgoing_volume,
    s.incoming_txns,
    s.outgoing_txns,
    s.pass_through_ratio,
    c.risk_rating,
    c.customer_type,
    c.annual_income,
    c.expected_monthly_volume
   FROM scored s
     JOIN customers c ON s.customer_id::text = c.customer_id::text
  WHERE s.incoming_volume >= 5000::numeric AND s.pass_through_ratio >= 0.8 AND s.pass_through_ratio <= 1::numeric
  ORDER BY s.pass_through_ratio DESC, s.customer_id;