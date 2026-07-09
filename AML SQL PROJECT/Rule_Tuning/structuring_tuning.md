# Structuring Detection - Rule Tuning

## Objective

Evaluate whether repeated structuring behaviour provides a stronger indicator of suspicious activity than isolated cash deposit events.

---

## Rule Evolution

| Version | Enhancement                        | Purpose                                                                              |
| ------- | ---------------------------------- | ------------------------------------------------------------------------------------ |
| V1      | Daily aggregation of cash deposits | Identify customers making multiple cash deposits on the same day.                    |
| V2      | Transaction drill-down             | Validate candidate alerts by reviewing the underlying transactions.                  |
| V3      | Recurrence analysis                | Measure how frequently customers exhibited the same behaviour across different days. |

---

## Baseline Rule

A suspicious day was defined as:

* Cash Deposit Count ≥ 2 on the same day

The final rule measured the number of suspicious days for each customer.

---

## Threshold Experiment – Behaviour Recurrence

| Version | Recurrence Threshold | Customers Flagged | Reduction vs Baseline | Observation                                                                                                                    |
| ------- | -------------------: | ----------------: | --------------------: | ------------------------------------------------------------------------------------------------------------------------------ |
| V1      |    ≥1 Suspicious Day |                 4 |                     — | One customer exhibited repeated behaviour across 10 separate days, while the remaining three customers were flagged only once. |
| V2      |   ≥2 Suspicious Days |                 1 |                 75.0% | Only the repeat offender remained. Three one-off occurrences were excluded.                                                    |
| V3      |   ≥3 Suspicious Days |                 1 |                 75.0% | No additional reduction.                                                                                                       |
| V4      |   ≥5 Suspicious Days |                 1 |                 75.0% | No additional reduction.                                                                                                       |

---

## Insight

The recurrence threshold effectively separated persistent behavioural patterns from isolated events. However, because the baseline rule already produced a very small alert population (4 customers), applying a stricter recurrence threshold substantially reduced analyst visibility while providing only a marginal operational benefit.

---

## Rule Tuning Summary

| Parameter Tested         | Impact   | Assessment                                                                                                           |
| ------------------------ | -------- | -------------------------------------------------------------------------------------------------------------------- |
| Daily Deposit Count (≥2) | High     | Primary behavioural filter identifying potential structuring events.                                                 |
| Behaviour Recurrence     | Moderate | Valuable for prioritising alerts but overly restrictive as an alert-generation threshold within the current dataset. |

---

## Recommended Production Rule

Generate an alert when:

* Cash Deposit Count ≥ 2 on the same day.

Use the number of suspicious days as an investigation prioritisation metric rather than an alert suppression threshold.

Suggested prioritisation:

* 1 Suspicious Day → Medium Priority
* 2–4 Suspicious Days → High Priority
* ≥5 Suspicious Days → Critical Priority

---

## Key Learning

This investigation demonstrated that repeated behavioural patterns provide valuable investigative context beyond a single rule hit. Rather than eliminating one-off events, recurrence is better utilised as a prioritisation mechanism to help investigators focus on customers exhibiting persistent structuring behaviour while maintaining visibility of isolated but potentially significant events.
