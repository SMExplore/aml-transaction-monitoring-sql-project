# /*

INVESTIGATION 05
Rapid Movement of Funds (Rule Validation Exercise)
==================================================

Business Objective:
Identify customers who rapidly move funds out after
receiving them, a behaviour commonly associated
with layering, mule accounts, and pass-through
activity.

Investigation Evolution:

Version 1:

* Transaction-to-transaction matching
* Incoming transaction followed by outgoing
  transaction within 24 hours

Finding:

* Multiple outgoing transactions matched to the
  same incoming transaction
* Excessive noise and overcounting

Version 2:

* Customer-day aggregation
* Daily incoming and outgoing volumes

Finding:

* More meaningful representation of account
  activity
* Reduced duplicate matching

Version 3:

* Pass-through ratio introduced
* Customer enrichment performed
* Alert validation completed

Finding:

* Highest-ranked candidates were legitimate
  businesses with expected high transaction
  volumes

Final Outcome:
Rule Validation Exercise

The scenario successfully identified same-day
pass-through activity but generated a large number
of likely false positives when reviewed against
customer profiles.
*/

WITH daily_flows AS (

```
SELECT
    customer_id,
    transaction_datetime::date AS txn_date,

    SUM(
        CASE
            WHEN direction = 'IN'
            THEN amount
            ELSE 0
        END
    ) AS incoming_volume,

    SUM(
        CASE
            WHEN direction = 'OUT'
            THEN amount
            ELSE 0
        END
    ) AS outgoing_volume,

    COUNT(
        CASE
            WHEN direction = 'IN'
            THEN 1
        END
    ) AS incoming_txns,

    COUNT(
        CASE
            WHEN direction = 'OUT'
            THEN 1
        END
    ) AS outgoing_txns

FROM transactions

GROUP BY
    customer_id,
    transaction_datetime::date
```

),

scored AS (

```
SELECT
    *,
    outgoing_volume / NULLIF(incoming_volume,0)
        AS pass_through_ratio
FROM daily_flows
```

)

SELECT
s.*,
c.risk_rating,
c.customer_type,
c.annual_income,
c.expected_monthly_volume

FROM scored s

JOIN customers c
ON s.customer_id = c.customer_id

WHERE incoming_volume >= 5000
AND pass_through_ratio BETWEEN 0.8 AND 1

ORDER BY
pass_through_ratio DESC,
customer_id;
