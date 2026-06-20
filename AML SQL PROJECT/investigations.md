# Investigation 1: Funnel Account Behaviour Detection

## Objective

Identify customers who receive funds from multiple counterparties and subsequently transfer a significant proportion of those funds out of their accounts.

This investigation aims to detect potential funnel account or pass-through account behaviour, which can be associated with layering activity, money mule networks, informal remittance activity, or other unusual fund movement patterns.

## Detection Methodology

The investigation was performed in two stages.

### Stage 1: Candidate Population Identification

Customers were selected if they met both of the following criteria:

* Received funds from at least 10 unique counterparties
* Total inbound transaction volume exceeded 5 times their declared annual income

This step was designed to identify customers whose inbound activity appeared inconsistent with their expected financial profile.

### Stage 2: Pass-Through Behaviour Assessment

For the identified population, outbound transaction activity was analysed.

Customers were retained if:

* Outbound transaction volume exceeded 80% of inbound transaction volume
* Outbound transaction volume remained lower than inbound transaction volume

This logic was intended to identify accounts where incoming funds were rapidly redistributed rather than retained.

## SQL Techniques Used

* Common Table Expressions (CTEs)
* Aggregations
* HAVING clauses
* Multi-table joins
* Distinct counterparty analysis
* Behavioural threshold logic

## Key Risk Indicators

The investigation combines multiple behavioural indicators:

1. Large number of unique inbound counterparties
2. Inbound volume significantly exceeding customer income
3. High outbound volume relative to inbound volume
4. Potential pass-through fund movement patterns

## Investigation Query

See:

sql/01_funnel_account_behaviour.sql

## Learning Outcomes

Through this investigation I practiced:

* Building AML detection logic using SQL
* Creating multi-stage investigation workflows
* Applying behavioural monitoring concepts
* Analysing customer transaction patterns
* Translating AML typologies into executable SQL rules

# Investigation 2: Dormant Account Reactivation

## Objective

Detect customers exhibiting prolonged inactivity followed by potentially unusual transaction activity.

## Detection Logic

### Step 1 – Identify Dormancy Events

A customer was considered dormant when the gap between two consecutive transactions exceeded 180 days.

### Step 2 – Measure Post-Reactivation Activity

For each reactivation event, transaction activity occurring within 30 days of reactivation was measured.

Metrics calculated:

* Total transaction volume
* Total transaction count
* Annual income
* Expected monthly volume
* Expected transaction count

### Step 3 – Apply Behavioural Thresholds

The following conditions were used to highlight potentially unusual activity:

* Volume > 2 × Expected Monthly Volume
* Volume > Annual Income
* Dormancy Period > 300 Days

### Step 4 – Behavioural Baseline Comparison

A volume multiple metric was calculated:

```text
Actual 30-Day Volume / Expected Monthly Volume
```

This enabled comparison of observed activity against expected customer behaviour.

## Example Observations

Examples identified during testing included:

* Customers generating transaction volumes greater than their annual income shortly after reactivation.
* Customers whose activity exceeded expected monthly volume by more than 10x.
* Customers reactivating after more than 500 days of inactivity.

## AML Interpretation

Dormant account reactivation does not inherently indicate suspicious activity. However, reactivation combined with significant behavioural changes may warrant further investigation.

Potential explanations include:

* Account takeover
* Money mule activity
* Layering behaviour
* Legitimate changes in customer circumstances

The objective of the rule is to identify behavioural anomalies requiring review rather than to determine suspicious activity directly.

