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
