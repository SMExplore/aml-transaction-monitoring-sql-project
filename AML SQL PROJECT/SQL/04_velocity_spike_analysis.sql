/*
Investigation 04 – Transaction Velocity Spike Analysis

Objective:
Identify customers whose monthly transaction frequency exceeds their historical baseline.

Development Stages:

1. Monthly Transaction Aggregation
2. Historical Baseline Creation
3. Spike Multiple Calculation
4. Customer Enrichment
5. Alert Quality Assessment

Key Learning:

Large behavioural spikes do not necessarily indicate suspicious activity.

Review of results highlighted the importance
of threshold calibration and false-positive
reduction in Transaction Monitoring systems.
*/

-- Version 1: Monthly Transaction Counts

SELECT
    customer_id,
    DATE_TRUNC('month', transaction_datetime) AS txn_month,
    COUNT(*) AS monthly_txn_count
FROM transactions
GROUP BY 1,2
ORDER BY 1,2

-- Version 2: Historical Baseline

WITH monthly_counts AS (

    SELECT
        customer_id,
        DATE_TRUNC('month', transaction_datetime) AS txn_month,
        COUNT(*) AS monthly_txn_count
    FROM transactions
    GROUP BY 1,2

)

SELECT
    customer_id,
    txn_month,
    monthly_txn_count,
    AVG(monthly_txn_count)
        OVER (
            PARTITION BY customer_id
        ) AS avg_monthly_count
FROM monthly_counts

-- Version 3: Candidate Review

WITH monthly_counts AS (

    SELECT
        customer_id,
        txn_month,
        monthly_txn_count,
        AVG(monthly_txn_count)
            OVER (
                PARTITION BY customer_id
            ) AS avg_monthly_count
    FROM (

        SELECT
            customer_id,
            DATE_TRUNC('month', transaction_datetime) AS txn_month,
            COUNT(*) AS monthly_txn_count
        FROM transactions
        GROUP BY 1,2

    ) x

)

SELECT
    mc.*,
    monthly_txn_count / avg_monthly_count AS spike_multiple,
    c.risk_rating,
    c.expected_transaction_count,
    c.customer_type,
    c.country

FROM monthly_counts mc

JOIN customers c
    ON mc.customer_id = c.customer_id

WHERE monthly_txn_count >= 15

ORDER BY spike_multiple desc

