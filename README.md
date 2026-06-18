# AML Transaction Monitoring SQL Project

## Overview

This project simulates AML (Anti-Money Laundering) and Transaction Monitoring investigations using synthetic banking data loaded into PostgreSQL and queried through DBeaver.

The objective is to showcase practical SQL skills relevant to:

- AML Operations
- Transaction Monitoring (TM)
- FCC Analysis
- Financial Crime Investigations
- RegTech Operations

## Environment

- PostgreSQL
- DBeaver
- SQL
- GitHub

## Dataset

- Customers: 1,000
- Transactions: 100,000
- Period Covered: 24 months
- Synthetic data only (no real customer information)

## Investigations Completed

### Investigation 1 – Funnel Account Behaviour
Developed SQL logic to identify customers receiving funds from many counterparties and redistributing most of those funds outward.
### Sample Output

See investigation results:

![Funnel Account Results](../AML SQL PROJECT/Screenshots/funnel_account_results.png)


## SQL Techniques Demonstrated

- Joins
- Aggregations
- GROUP BY
- HAVING
- Common Table Expressions (CTEs)
- Behavioural Analysis
- Ratio-based Detection Logic

## Future Enhancements

- Structuring Detection 
- Dormant Account Reactivation
- Velocity monitoring
- Counterparty clustering
- Alert generation simulation
- Case management simulation
- Rule tuning exercises
