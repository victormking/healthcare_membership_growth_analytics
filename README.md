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
```

## 🧭 Mini ERD (Schema Overview)

```mermaid
erDiagram
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
## 📊 Analytical Workflow (Stage 2 → Q01–Q14)

After building the SQL semantic layer, the project answers **14 structured analytical questions**, each representing a real-world KPI used by healthcare membership, marketing, and growth teams.

| # | Business Question | Output |
|---|--------------------|---------|
| **Q01** | Monthly lead volume | `q01_leads_by_month.csv` |
| **Q02** | Lead → Member conversion rate | `q02_conversion_rate.csv` |
| **Q03** | Average days to convert | `q03_days_to_convert.csv` |
| **Q04** | Conversion rate by channel | `q04_channel_conversion.csv` |
| **Q05** | Campaign-level CPA | `q05_campaign_cpa.csv` |
| **Q06** | Campaign ROI | `q06_campaign_roi.csv` |
| **Q07** | Channel efficiency (CPA + ROI) | `q07_channel_efficiency.csv` |
| **Q08** | Engagement tier distribution | `q08_engagement_tiers.csv` |
| **Q09** | Events per member | `q09_events_per_member.csv` |
| **Q10** | Revenue by product category | `q10_revenue_by_product.csv` |
| **Q11** | ARPO (Average Revenue Per Organization) | `q11_arpo.csv` |
| **Q12** | Renewal rate by engagement tier | `q12_renewal_by_engagement.csv` |
| **Q13** | Time-to-convert by channel | `q13_days_to_convert_by_channel.csv` |
| **Q14** | High-intent channel analysis | `q14_high_intent_channels.csv` |

Each KPI was exported to `/data/answers/` in CSV format to support dashboard development and further analysis.

---

## 💡 Stage 3 — Insights & Recommendations

This stage summarizes key insights identified across the acquisition, engagement, revenue, and renewal lifecycle of the healthcare membership model.

### **1. Funnel Performance**
- ~60,000 leads across all channels  
- ~14,940 conversions  
- Overall conversion rate ≈ **25%**  
- Funnel is healthy but overly dependent on a small set of high-performing channels

### **2. Channel Effectiveness**
- **Email** is the strongest channel by both volume and efficiency  
- **Paid Ads** scale well but deliver lower ROI  
- **Webinars** are high-intent but underfunded  
- **Referrals + Website** deliver excellent quality leads despite lower volume  
- **Social** produces the weakest funnel performance

### **3. Time-to-Convert**
- Average time to convert ≈ **49 days**  
- Conversion velocity is similar across channels, indicating a consistent, consideration-driven buyer journey

### **4. Strategic Recommendations**
- Reallocate **12–18%** of budget toward high-intent channels  
- Build “Decision Assist” nurture sequences to accelerate conversions  
- Expand segmentation to increase relevance of email campaigns  
- Boost awareness for Referral and Webinar channels  
- Streamline mid-funnel experience to shorten the 49-day cycle

### **5. 90-Day Plan**
- Channel budget rebalancing  
- Funnel acceleration program  
- Advanced segmentation rollout  
- Awareness expansion  
- Enhanced reporting cadence for growth & leadership teams  

---

## 📈 Stage 4 — Dashboards & Visualization (Power BI)

The final Power BI dashboard translates the SQL-based KPI engine into clear, actionable visual insights for marketing, membership, and leadership teams. The dashboard consists of **two pages**, each focused on a different part of the growth lifecycle.

### **Page 1 — Growth Overview**
- Monthly lead volume  
- Lead → Member conversion rate  
- Channel-level conversion performance  
- Campaign CPA & ROI  
- Revenue by product category  
- KPI cards summarizing:
  - Total leads  
  - Total conversions  
  - Average days to convert  
  - Highest-performing channels  

### **Page 2 — Engagement & Retention**
- Engagement tier distribution (Low / Medium / High)  
- Events per member  
- Renewal rate by engagement tier  
- Organization-level revenue metrics (ARPO)  
- Retention vs. engagement scatterplots  

These visuals combine to form a complete story of **acquisition → engagement → revenue → renewal**, mirroring the workflow used by real-world healthcare membership organizations.

---

## 🧱 Folder Structure

```plaintext
healthcare_membership_growth/
├── data/                     # Raw tables + exported view & KPI outputs
├── sql_views/                # SQL scripts for all Stage 1 engineered views
├── sql_queries/              # Stage 2 analytical KPI queries (Q01–Q14)
├── powerbi/                  # Power BI dashboard files (PBIX)
├── docs/                     # Insights, notes, and supporting documentation
├── .gitignore
└── README.md

---

© 2025 Victor King — Project for portfolio demonstration.  
Licensed under the [MIT License](./LICENSE).
