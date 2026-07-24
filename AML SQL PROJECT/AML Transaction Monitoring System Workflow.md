# AML Transaction Monitoring System Workflow

## Overview

This project simulates the end-to-end workflow of an Anti-Money Laundering (AML) Transaction Monitoring system.

Using synthetic customer and transaction data, SQL-based detection rules identify suspicious activity, generate alerts, simulate investigator case management, and produce reporting views that power interactive Tableau dashboards.

The objective is to demonstrate both SQL implementation and an understanding of operational AML investigation workflows.

---

## End-to-End Workflow
<img width="517" height="318" alt="Screenshot 2026-07-24 115131" src="https://github.com/user-attachments/assets/0364b076-cf1a-4c4f-ba1a-9b356efcbc07" />


---

## Detection Rules

Five SQL-based Transaction Monitoring (TM) scenarios were developed to identify potentially suspicious customer behaviour.

| Detection Rule | Purpose |
|----------------|---------|
| Rapid Movement of Funds | Detect customers rapidly transferring incoming funds to other accounts. |
| Velocity Spike | Identify unusually high transaction frequency within a short period. |
| Dormant Account Reactivation | Detect significant activity following prolonged account inactivity. |
| Structuring | Identify multiple cash deposits that may indicate attempts to avoid reporting thresholds. |
| Funnel Account Behaviour | Detect accounts exhibiting high pass-through activity and multiple counterparties. |

Each detection rule produces a list of customers whose transaction activity meets predefined monitoring criteria.

---

## Alert Management

Customers meeting one or more detection rules are converted into transaction monitoring alerts.

Each alert represents a potential indicator of suspicious activity requiring review and includes information such as:

- Detection rule
- Customer
- Alert date
- Risk metric
- Alert status

Alerts are assigned one of the following statuses:

| Alert Status | Description |
|--------------|-------------|
| Assigned | Alert remains in the investigation queue. |
| False Positive | Review determined the alert did not require further investigation. |
| Converted to Case | Alert escalated into a formal investigation case. |

---

## Investigation & Case Management

Alerts escalated for investigation become cases managed by an assigned investigator.

Each investigation includes:

- Customer profile review
- Customer risk assessment
- Detection rules triggered
- Investigation notes
- Case disposition

Cases may contain one or more related alerts for the same customer, simulating how investigators consolidate related suspicious activity into a single investigation.

---

## Case Outcomes

Following investigation, each case receives a final disposition.

The simulated workflow includes:

- Monitoring Continued
- SAR Recommended

These outcomes represent common operational decisions made during the AML investigation process.

---

## Reporting & Analytics

SQL reporting views were created to transform operational data into dashboard-ready datasets.

These views power three interactive Tableau dashboards:

| Dashboard | Purpose |
|-----------|---------|
| Executive Monitoring Dashboard | Portfolio-level view of alerts, cases, detection rule performance and investigator workload. |
| Investigation Operations Dashboard | Operational monitoring of case volumes, investigator performance and investigation outcomes. |
| Customer 360 Investigation | Consolidated customer view including profile, alerts, investigation history and investigator notes. |

---

## Technologies Used

- PostgreSQL
- SQL
- Tableau
- GitHub

---

## Skills Demonstrated

### SQL & Data Engineering

- Relational database design
- Common Table Expressions (CTEs)
- Window Functions
- Complex Joins
- Reporting View Development
- Synthetic Data Modelling

### AML & Financial Crime

- Transaction Monitoring
- Rule-Based Detection
- Alert Management
- False Positive Analysis
- Case Management
- Investigation Workflow

### Analytics & Visualisation

- KPI Design
- Dashboard Development
- Operational Reporting
- Customer 360 Analytics

---

## Project Summary

This project demonstrates the complete lifecycle of a simulated AML Transaction Monitoring platform—from transaction analysis and SQL-based detection rules through alert generation, investigation, case management and executive reporting.

Rather than focusing solely on SQL queries, the project models how operational Transaction Monitoring systems support investigators and compliance teams in identifying, reviewing and managing potentially suspicious financial activity.
