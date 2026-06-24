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

# Investigation 03 – Structuring / Smurfing Detection

## Objective

Identify customers potentially splitting cash deposits into multiple smaller transactions over time.

## Business Rationale

Structuring (also known as smurfing) is a common money laundering typology in which larger amounts are broken into multiple smaller deposits to avoid detection or reporting thresholds.

The purpose of this investigation was not to identify large deposits, but rather to identify behavioural patterns consistent with repeated cash deposit structuring.

---

## Investigation Development

### Version 1 – Daily Cash Deposit Analysis

The investigation began by analysing cash deposit activity at a customer-day level.

Metrics calculated:

* Daily deposit volume
* Daily deposit count

Candidate customers were identified where:

* Daily deposit volume exceeded expected monthly volume
* Deposit count was at least 2

This produced a small candidate population for further review.

### Observation

The initial query identified only a limited number of customer-days.

This suggested that the thresholds were highly selective and required further validation.

---

### Version 2 – Transaction Drill-Down

The candidate population was joined back to the transaction table to review the underlying deposits.

Example patterns observed:

* Multiple cash deposits on the same day
* Deposits of similar amounts
* Deposits clustered within a short period

Examples included:

* 9,397 and 9,434 on the same day
* 8,183, 8,009 and 9,526 on the same day

This provided stronger evidence of potential deposit splitting behaviour.

---

### Version 3 – Recurrence Analysis

A key question emerged:

Was the behaviour a one-off event or a repeated pattern?

To answer this, suspicious customer-days were aggregated by customer.

Results:

| Customer  | Suspicious Days |
| --------- | --------------- |
| CUST00105 | 10              |
| CUST00009 | 1               |
| CUST00177 | 1               |
| CUST00995 | 1               |

### Observation

Most customers appeared only once.

However, CUST00105 exhibited the pattern across ten separate days spanning multiple months.

This significantly increased the risk relevance of the behaviour.

---

### Version 4 – Final Interpretation

The investigation demonstrated that repeated behaviour was a more meaningful signal than a single occurrence.

The strongest indicator was not:

* Large cash deposits

but rather:

* Multiple cash deposits
* Similar deposit amounts
* Repeated occurrence across multiple dates

This transformed the investigation from a simple cash activity review into a behavioural structuring detection exercise.

---

## SQL Techniques Demonstrated

* Common Table Expressions (CTEs)
* Date bucketing
* Aggregations
* Behavioural threshold analysis
* Multi-stage investigations
* Transaction drill-down analysis
* Customer enrichment
* Pattern validation

---

## Key Learning

An important lesson from this investigation was that transaction monitoring rules should be iteratively refined.

The original hypothesis focused on identifying unusual cash deposit activity.

Reviewing the underlying transactions revealed that recurring behavioural patterns provided a stronger signal than transaction value alone.

This mirrors the process of transaction monitoring rule tuning, where candidate populations are reviewed and thresholds are refined based on observed behaviour.

# Investigation 04 – Transaction Velocity Spike Analysis

## Objective

Identify customers whose monthly transaction frequency significantly exceeded their historical baseline.

## Business Rationale

Transaction Monitoring systems frequently use velocity-based rules to identify sudden increases in account activity that may indicate account takeover, money mule activity, fraud, or changes in customer behaviour.

The objective was to determine whether transaction frequency anomalies could be detected using behavioural baselines.

---

## Investigation Development

### Version 1 – Monthly Transaction Counts

Monthly transaction counts were calculated for every customer.

Metrics calculated:

- Customer ID
- Transaction Month
- Monthly Transaction Count

### Version 2 – Historical Baseline

A customer-specific baseline was created using a window function.

For each customer:

Average Monthly Transaction Count = Historical Average Transaction Count

This enabled comparison against the customer's own historical behaviour rather than against arbitrary thresholds.

### Version 3 – Spike Multiple

A behavioural metric was introduced:

Spike Multiple = Monthly Transaction Count / Average Monthly Transaction Count

This highlighted months where activity significantly exceeded historical norms.

### Version 4 – Candidate Review

Additional customer attributes were added:

- Risk Rating
- Customer Type
- Country
- Expected Transaction Count

Candidate months with at least 15 transactions were reviewed.

---

## Findings

Several customers exhibited transaction counts between 3x and 6x their historical monthly average.

Examples included:

- Customers averaging fewer than 3 monthly transactions who subsequently generated 15–20 transactions in a single month.
- Customers exhibiting frequency spikes greater than 4x historical behaviour.

However, review of the results indicated that many of the highest multiples were driven by very low historical baselines rather than exceptionally high transaction volumes.

---

## Key Observation

A large spike multiple does not necessarily imply suspicious behaviour.

For example:

Average Monthly Count = 2

Current Month Count = 10

Spike Multiple = 5x

Although mathematically significant, the underlying transaction volume may still be relatively modest.

---

## Conclusion

The methodology successfully identified frequency anomalies but generated a population with limited investigative value.

This investigation demonstrated the importance of:

- Threshold calibration
- Alert quality assessment
- False-positive reduction
- Rule tuning

Future enhancements could include:

- Hourly velocity analysis
- Daily velocity analysis
- Volume-based thresholds
- Combined behavioural indicators

---

## SQL Techniques Demonstrated

- DATE_TRUNC()
- Window Functions (AVG OVER)
- Behavioural Baselines
- Anomaly Scoring
- Customer Enrichment
- Rule Validation

# Investigation 05 – Rapid Movement of Funds (Rule Validation Exercise)

## Objective

Rapid movement of funds is a common AML typology where money enters an account and is quickly transferred elsewhere with little retention of funds. Such behaviour may indicate layering, funnel account activity, mule account usage, or other forms of financial crime.

The objective of this investigation was to identify customers who rapidly moved funds after receiving them and evaluate whether this behaviour could be detected using SQL-based transaction monitoring logic.

---

## Initial Hypothesis

Customers exhibiting rapid movement behaviour would:

* Receive incoming funds
* Transfer a significant portion of those funds out shortly afterwards
* Retain little of the incoming amount

A high ratio of outgoing funds to incoming funds was expected to highlight potential pass-through account behaviour.

---

## Iteration 1 – Transaction Pair Analysis

### Methodology

The first approach attempted to identify incoming transactions followed by outgoing transactions within a 24-hour window.

The logic matched:

* Incoming transaction (IN)
* Outgoing transaction (OUT)
* Same customer
* Outgoing transaction occurring within 24 hours of the incoming transaction

### Example Results

| Customer  | Incoming Amount | Outgoing Amount | Time Gap |
| --------- | --------------- | --------------- | -------- |
| CUST00001 | 9,283.95        | 2,295.92        | 15 hours |
| CUST00001 | 4,110.26        | 1,555.88        | 11 hours |

### Findings

The query successfully identified transactions occurring close together in time. However, the same incoming transaction was often matched against multiple outgoing transactions.

This created a many-to-many relationship and made it difficult to determine whether the outgoing activity was genuinely related to the incoming funds.

### Conclusion

The approach generated excessive noise and did not accurately measure pass-through behaviour.

---

## Iteration 2 – Daily Flow Analysis

### Methodology

To reduce noise, transactions were aggregated at customer-day level.

For each customer and day:

* Total Incoming Volume
* Total Outgoing Volume
* Incoming Transaction Count
* Outgoing Transaction Count

were calculated.

A Pass Through Ratio was then created:

Pass Through Ratio = Outgoing Volume / Incoming Volume

---

## Iteration 3 – Threshold Tuning

The following thresholds were applied:

* Incoming Volume >= 5,000
* Pass Through Ratio between 0.80 and 1.00

The intention was to identify customers moving 80%–100% of incoming funds out on the same day.

---

## Sample Results

| Customer  | Incoming Volume | Outgoing Volume | Pass Through Ratio |
| --------- | --------------- | --------------- | ------------------ |
| CUST00412 | 37,249          | 37,249          | 0.9999             |
| CUST00103 | 46,649          | 46,325          | 0.9931             |
| CUST00849 | 50,543          | 49,916          | 0.9876             |

These customers appeared to move almost all incoming funds out on the same day.

---

## Customer Profile Review

To validate the alerts, customer information was enriched from the customer master table.

Example matches:

| Customer  | Type     | Annual Income | Expected Monthly Volume |
| --------- | -------- | ------------- | ----------------------- |
| CUST00412 | Business | 462,800       | 19,700                  |
| CUST00103 | Business | 1,633,600     | 118,300                 |
| CUST00849 | Business | 1,563,300     | 99,200                  |

The highest-ranked results were predominantly business customers with large expected transaction volumes.

---

## Key Findings

The rule successfully identified customers exhibiting high same-day pass-through behaviour.

However, review of customer profiles showed that most alerts were generated on legitimate business customers whose transaction activity was consistent with their expected business operations.

This indicated that the rule was detecting normal commercial cash flow rather than suspicious rapid movement.

---

## Lessons Learned

Several important transaction monitoring lessons emerged from this exercise:

1. A technically correct SQL query does not necessarily detect the intended financial crime behaviour.

2. Rapid movement metrics should not be assessed in isolation.

3. Customer context is critical when evaluating transaction monitoring alerts.

4. Rule thresholds must be validated against actual customer populations to reduce false positives.

5. Effective TM scenarios often require multiple dimensions of risk, including customer profile, transaction behaviour, historical activity, and counterparty relationships.

---

## Final Assessment

This investigation should be considered a Rule Validation Exercise rather than a successful detection scenario.

While the SQL logic correctly identified high pass-through activity, the resulting alert population consisted primarily of legitimate business customers.

Future enhancements could include:

* Comparing activity against customer historical baselines
* Incorporating balance movements
* Including counterparty concentration analysis
* Applying customer-type-specific thresholds
* Combining pass-through behaviour with high-risk jurisdiction exposure

---

## Skills Demonstrated

* Common Table Expressions (CTEs)
* Conditional Aggregation
* Behavioural Analytics
* Ratio Analysis
* Customer Enrichment
* Threshold Tuning
* Rule Validation
* False Positive Analysis
* AML Transaction Monitoring Methodology
