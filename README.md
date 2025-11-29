# 🏥 Healthcare Membership Growth Analytics  
### End-to-End SQL Membership, Marketing & Retention Analysis (SQL Server + Power BI Project)
---

## 🧭 Overview

This project simulates the **data analytics workflow of a Healthcare Membership & Growth Strategy team** — analyzing lead acquisition, funnel performance, member conversions, engagement patterns, and renewal behavior using **SQL Server** and **Power BI**.

It demonstrates a complete **end-to-end growth analytics pipeline**, from raw CSV ingestion to engineered SQL views, KPI development, business insights, and final dashboard delivery.

The dataset reflects a realistic **healthcare association CRM environment**, similar to how membership organizations operate when tracking lead quality, campaign impact, member engagement, and renewal outcomes.

---
<p align="center">
  <img src="https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white" />
  <img src="https://img.shields.io/badge/SQL-336791?style=for-the-badge&logo=postgresql&logoColor=white" />
  <img src="https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black" />
  <img src="https://img.shields.io/badge/Windows_11-0078D6?style=for-the-badge&logo=windows11&logoColor=white" />
  <img src="https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white" />
</p>

---

## 🚀 Quickstart

Clone the repo and open SQL Server Management Studio (SSMS) from the project root:

1. Create a new database:

```sql
CREATE DATABASE healthcare_growth;
GO
---

## 🧭 Mini ERD (Schema Overview)

```erDiagram
  organizations ||--o{ members : contains
  members ||--o{ engagement_events : engages
  members ||--o{ product_sales : purchases
  leads ||--o{ members : converts
  campaigns ||--o{ campaign_touches : delivers
  leads ||--o{ campaign_touches : receives
```

## 🎯 Project Objectives

1. **Build a unified membership analytics framework** across multiple healthcare CRM data sources.  
2. **Evaluate lead acquisition and conversion performance** across channels and campaigns.  
3. **Analyze engagement behavior** and segment members into activity tiers for monitoring and retention.  
4. **Measure revenue and product performance** across organizations, members, and product categories.  
5. **Understand renewal likelihood** based on engagement, touchpoints, and lifetime behavior.  
6. **Simulate an industry-standard analytics workflow** used by healthcare associations, membership groups, and marketing teams.

---

**## 🧩 Dataset Schema

The raw data consists of **7 base CSVs**, each representing a key operational dataset in the healthcare membership lifecycle:

| File | Description |
|------|-------------|
| `organizations.csv` | Organization-level accounts (practice, clinic, health system), size, industry, and region |
| `members.csv` | Individual members linked to organizations, with join dates and role information |
| `leads.csv` | Top-of-funnel lead records with source, channel, inquiry date, and conversion status |
| `campaigns.csv` | Marketing campaign metadata including channel, budget, start/end dates, and objectives |
| `campaign_touches.csv` | Touch-level interactions (email, webinar invites, ads) with open/click/response flags |
| `engagement_events.csv` | Webinars, logins, course completions, downloads, and other member engagement events |
| `product_sales.csv` | Membership purchases, renewals, and product revenue by member and organization |

All records are **synthetic**, generated to mimic a realistic healthcare membership CRM while avoiding any real PII.

---

## 🏗️ Data Engineering (Stage 1 → Views)

From these 7 raw tables, we engineered **7 analytical views** in SQL Server, each designed to support downstream growth, engagement, and retention analysis:

| View | Purpose | Engineered Columns |
|------|----------|--------------------|
| `v_lead_funnel` | Centralized view of the lead → member funnel across channels and campaigns | `lead_id`, `member_id`, `channel`, `campaign_id`, `inquiry_date`, `conversion_date`, `days_to_convert`, `converted_flag` |
| `v_campaign_performance` | Campaign-level performance and economics for marketing and growth teams | `campaign_id`, `channel`, `spend`, `lead_count`, `conversion_count`, `conv_rate`, `cpa`, `roi` |
| `v_channel_performance` | Channel rollups to compare acquisition efficiency and velocity | `channel`, `lead_count`, `conversion_count`, `conv_rate`, `avg_days_to_convert`, `cpa`, `roi` |
| `v_engagement_summary` | Member-level engagement features derived from event logs | `member_id`, `events_count`, `last_event_date`, `days_since_last_event`, `engagement_tier` (e.g., Low/Med/High) |
| `v_revenue_summary` | Revenue aggregation across products, members, and organizations | `organization_id`, `member_id`, `product_category`, `revenue_total`, `revenue_12m`, `arpo` |
| `v_member_360` | Unified member profile combining funnel, engagement, and revenue features | `member_id`, `organization_id`, `channel_first_touch`, `days_to_convert`, `engagement_tier`, `lifetime_value`, `renewal_flag` |
| `v_retention_cohorts` | Cohort-style view to track renewal and churn behavior over time | `cohort_month`, `member_id`, `renewal_flag`, `churn_flag`, `renewal_cycle`, `renewal_rate` |

Each view is created via T-SQL in SQL Server and can be exported as CSV for validation or loaded directly into Power BI.

---


