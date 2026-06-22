# AML Transaction Monitoring Investigation Log

---

# Investigation 01 – Funnel Account / Pass-Through Behaviour

## Objective

Identify customers receiving funds from multiple counterparties and subsequently transferring a significant proportion of those funds out of their accounts.

## Business Rationale

Funnel or pass-through accounts are commonly monitored within Transaction Monitoring programmes as they may indicate money mule activity, layering behaviour, informal value transfer, or other unusual movement of funds.

## Detection Logic

### Stage 1 – Candidate Population

Customers satisfying both conditions:

* At least 10 unique inbound counterparties
* Total inbound volume greater than 5 × annual income

### Stage 2 – Outbound Behaviour

For the shortlisted customers:

* Calculate total outbound transaction volume
* Calculate unique outbound counterparties

Customers were retained where:

* Outbound volume exceeded 80% of inbound volume
* Outbound volume remained lower than inbound volume

## SQL Techniques

* Common Table Expressions (CTEs)
* Aggregations
* HAVING clauses
* Multi-table joins
* Behavioural threshold analysis

## Key Learning

A single indicator is rarely sufficient for transaction monitoring. Combining multiple behavioural characteristics significantly improves the quality of candidate selection.

---

# Investigation 02 – Dormant Account Reactivation

## Objective

Identify customers who remained inactive for extended periods and subsequently resumed activity at levels inconsistent with their expected behaviour.

## Business Rationale

Dormant account reactivation is a common Transaction Monitoring scenario. While reactivation is often legitimate, significant deviations from historical behaviour may indicate account takeover, money mule activity, layering, or other financial crime risks.

## Development Process

Rather than defining a fixed rule immediately, the investigation was developed iteratively.

### Version 1

Initial objective:

* Identify customers with more than 180 days between consecutive transactions.

A `LAG()` window function was used to calculate the previous transaction date for every customer.

### Version 2

The investigation was expanded to analyse activity occurring within 30 days of the reactivation event.

For each reactivated customer, the following metrics were calculated:

* Total transaction volume
* Transaction count
* Customer type
* Country
* Risk rating
* Annual income
* Expected monthly volume
* Expected transaction count

### Version 3

Initial review showed that transaction counts remained relatively low after reactivation, but transaction values were significantly higher than expected for several customers.

As a result, the investigation shifted from a transaction-count focus to a behavioural-volume focus.

### Version 4 (Current Rule)

Customers are retained when at least one of the following conditions is satisfied:

* Total 30-day volume exceeds **2 × Expected Monthly Volume**
* Total 30-day volume exceeds **Annual Income**
* Dormancy period exceeds **300 days**

An additional metric was introduced:

**Volume Multiple = Actual 30-Day Volume / Expected Monthly Volume**

This allows customer behaviour to be compared against an expected baseline rather than using absolute values alone.

## Sample Observations

The investigation identified examples of:

* Customers generating transaction volumes greater than their declared annual income shortly after reactivation.
* Customers exceeding expected monthly transaction volume by more than 10×.
* Customers reactivating after more than 500 days of inactivity.

These observations demonstrate how combining temporal analysis with behavioural thresholds produces more meaningful candidate populations than dormancy alone.

## SQL Techniques Demonstrated

* Window Functions (`LAG`)
* Date and interval calculations
* Common Table Expressions (CTEs)
* Behavioural monitoring logic
* Aggregations
* Threshold-based filtering
* Customer profile enrichment

## Analyst Notes

One important learning from this investigation was that threshold selection should be data-driven.

The initial assumption was that dormant accounts would reactivate with unusually high transaction counts. However, exploratory analysis showed that the more meaningful signal was unusually high transaction volume relative to expected customer behaviour.

This resulted in refining the rule to incorporate expected monthly volume and annual income comparisons, making the investigation more aligned with behavioural transaction monitoring practices.
