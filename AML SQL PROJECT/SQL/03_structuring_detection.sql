/*
Investigation 03 – Structuring / Smurfing Detection

Development Stages

1. Candidate Population Identification
2. Transaction Drill-Down
3. Recurrence Analysis

Key Finding:
Repeated cash deposit behaviour across multiple dates
provided a stronger signal than isolated high-value
cash deposit activity.
*/

-- Version 1: Candidate Population

WITH short_cust AS (
    SELECT
        t.customer_id,
        t.transaction_datetime::date AS transaction_date,
        SUM(t.amount) AS deposit_volume,
        COUNT(*) AS deposit_count
    FROM transactions t
    WHERE t.transaction_type = 'CASH_DEPOSIT'
    GROUP BY 1,2
)

SELECT
    sc.customer_id,
    sc.transaction_date,
    sc.deposit_volume,
    sc.deposit_count,
    c.annual_income,
    c.customer_type,
    c.expected_monthly_volume,
    c.risk_rating,
    sc.deposit_volume / c.expected_monthly_volume AS volume_multiple
FROM short_cust sc
JOIN customers c
    ON sc.customer_id = c.customer_id
WHERE sc.deposit_volume > c.expected_monthly_volume
  AND sc.deposit_count >= 2
ORDER BY 1,2,3

-- Version 2: Transaction Drill-Down

WITH short_cust AS (
    SELECT
        t.customer_id,
        t.transaction_datetime::date AS transaction_date,
        SUM(t.amount) AS deposit_volume,
        COUNT(*) AS deposit_count
    FROM transactions t
    WHERE t.transaction_type = 'CASH_DEPOSIT'
    GROUP BY 1,2
)

SELECT
    sc.customer_id,
    sc.transaction_date,
    t.transaction_datetime,
    t.amount
FROM short_cust sc
JOIN transactions t
    ON sc.customer_id = t.customer_id
   AND sc.transaction_date = t.transaction_datetime::date
WHERE sc.deposit_count >= 2
  AND t.transaction_type = 'CASH_DEPOSIT'
ORDER by 1, 3

-- Version 3: Recurrence Analysis

WITH short_cust AS (
    SELECT
        customer_id,
        transaction_datetime::date AS transaction_date,
        SUM(amount) AS deposit_volume,
        COUNT(*) AS deposit_count
    FROM transactions
    WHERE transaction_type = 'CASH_DEPOSIT'
    GROUP BY 1,2
)

SELECT
    customer_id,
    COUNT(*) AS suspicious_days
FROM short_cust
WHERE deposit_count >= 2
GROUP BY customer_id
ORDER BY suspicious_days DESC