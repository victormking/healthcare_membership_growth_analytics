🏥 Healthcare Membership Growth Analytics
End-to-End SQL Membership, Marketing & Retention Analysis (SQL Server + Power BI Project)
🧭 Overview

This project simulates the data analytics workflow of a Healthcare Membership & Growth Strategy team — analyzing lead acquisition, funnel performance, member conversions, revenue, engagement, and renewal behavior using SQL Server and Power BI.

It demonstrates a full end-to-end growth analytics pipeline, from multi-CSV ingestion to engineered SQL views, KPI development, analytical outputs, stakeholder insights, and dashboard visualization.

The dataset reflects a realistic healthcare association CRM environment, similar to the operational data structures used by organizations such as MGMA — where understanding how leads convert, how campaigns perform, and how members engage is central to revenue and retention.

<p align="center"> <img src="https://img.shields.io/badge/SQL_Server-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white" /> <img src="https://img.shields.io/badge/SQL-336791?style=for-the-badge&logo=postgresql&logoColor=white" /> <img src="https://img.shields.io/badge/Power_BI-F2C811?style=for-the-badge&logo=powerbi&logoColor=black" /> <img src="https://img.shields.io/badge/Windows_11-0078D6?style=for-the-badge&logo=windows11&logoColor=white" /> <img src="https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white" /> </p>
🧭 Mini ERD (Schema Overview)
erDiagram
  organizations ||--o{ members : contains
  members ||--o{ engagement_events : engages
  members ||--o{ product_sales : purchases
  leads ||--o{ members : converts
  campaigns ||--o{ campaign_touches : delivers
  leads ||--o{ campaign_touches : receives


This diagram represents the 7-table healthcare membership CRM schema:

leads → acquisition funnel

campaigns & campaign_touches → marketing engine

members → converted leads & active membership

organizations → group membership accounts

engagement_events → activity and usage

product_sales → revenue behavior

🎯 Project Objectives

Model a healthcare membership funnel from lead → conversion → retention.

Measure campaign & channel performance (CPA, ROI, conversion rate).

Analyze engagement patterns and segment members into L/M/H activity groups.

Understand revenue distribution across organizations & product categories.

Evaluate renewal likelihood based on behavior, touchpoints, and engagement.

Simulate an analytics workflow used in healthcare and association-driven businesses.

🧩 Dataset Schema

The project uses 7 synthetic CSV files, modeled after a real-world healthcare membership CRM:

File	Description
organizations.csv	Organization-level accounts, size, industry, region
members.csv	Member demographics, join dates, organization linkage
leads.csv	Lead source, channel, inquiry date, conversion status
campaigns.csv	Campaign metadata including spend, dates, and objectives
campaign_touches.csv	Individual marketing touches and engagement outcomes
engagement_events.csv	Webinars, logins, course completions, content activity
product_sales.csv	Membership purchases, renewals, and product revenue

All data is synthetic, generated via structured prompts and custom rules to resemble real healthcare membership operations.

🏗️ Data Engineering (Stage 1 → Views)

From the 7 raw tables, 7 analytic SQL views were created to streamline the KPI workflow:

View	Purpose	Engineered Columns
v_lead_funnel	Unified lead → member funnel data	days_to_convert, converted_flag
v_campaign_performance	Campaign-level CPA, conversion, ROI metrics	total_leads, total_conversions, cost_per_acquisition
v_channel_performance	Channel-level performance rollups	lead_volume, conv_rate, avg_days_to_convert
v_engagement_summary	Engagement buckets & activity metrics	events_count, engagement_tier
v_revenue_summary	Revenue metrics for product & organization segments	revenue_total, arpo
v_member_360	Comprehensive member-level feature table	engagement_tier, lifetime_value, org_industry
v_retention_cohorts	Renewal likelihood by cohort and segment	renewal_rate, churn_flag

📂 View outputs were exported into /data/views/ for validation.

📊 Analytical Workflow (Stage 2 → Q01–Q14)

After building the semantic layer, the project answers 14 structured growth KPIs, each representing a real-world business question.

#	Business Question	Output
Q01	Monthly lead volume	q01_leads_by_month.csv
Q02	Lead → Member conversion rate	q02_conversion_rate.csv
Q03	Average days to convert	q03_days_to_convert.csv
Q04	Conversion rate by channel	q04_channel_conversion.csv
Q05	Campaign-level CPA	q05_campaign_cpa.csv
Q06	Campaign ROI	q06_campaign_roi.csv
Q07	Channel efficiency (CPA + ROI)	q07_channel_efficiency.csv
Q08	Engagement tier distribution	q08_engagement_tiers.csv
Q09	Events per member	q09_events_per_member.csv
Q10	Revenue by product category	q10_revenue_by_product.csv
Q11	ARPO (Average Revenue Per Organization)	q11_arpo.csv
Q12	Renewal rate by engagement tier	q12_renewal_by_engagement.csv
Q13	Channel-level time-to-convert	q13_days_to_convert_by_channel.csv
Q14	High-intent channel analysis	q14_high_intent_channels.csv

Each SQL query follows the same pattern used in enterprise analytics teams: engineered views → aggregated KPIs → export-ready tables.

💡 Stage 3 — Insights & Recommendations

The analysis produced several executive-level insights across the acquisition, engagement, and retention lifecycle.

1. Funnel Performance

60,000 total leads

14,940 conversions

Overall conversion rate ≈ 25% (strong for healthcare membership)

Funnel is healthy, but dependent on a few strong channels

2. Channel Effectiveness

Email → strongest channel by both volume and efficiency

Paid Ads → high reach, lower ROI

Webinars → mid-volume, high-intent, underfunded

Referrals + Website → low volume but high-intent traffic

Social → low quality traffic, weak conversions

3. Time-to-Convert

Average ≈ 49 days

Very similar across channels

Indicates a fixed, consideration-driven sales cycle

4. Strategic Recommendations

Shift 12–18% of budget to high-intent channels

Accelerate mid-funnel velocity with “Decision Assist” sequences

Strengthen segmentation in Email campaigns

Increase awareness for Referral + Webinar channels

Improve nurture sequencing to shorten the 49-day cycle

5. 90-Day Plan

Channel rebalancing

Funnel acceleration

New segmentation strategy

Awareness expansion

Enhanced reporting cadence

📈 Stage 4 — Dashboards & Visualization

The final Power BI dashboard includes two pages:

Page 1 — Growth Overview

Lead volume

Conversion rate

Channel-level funnel metrics

Revenue by product category

KPI cards for days-to-convert & conversion efficiency

Page 2 — Engagement & Retention

Engagement tiers

Events per member

Renewal rate by engagement tier

Organization-level revenue metrics (ARPO)

The dashboard completes the end-to-end analytics workflow by translating the KPI engine into actionable visual storytelling.

⚙️ Technology Stack
Category	Tools
Database	SQL Server Express 17
Query Language	T-SQL
IDE	SSMS 22, VS Code
Visualization	Power BI
Data Export	SSMS CSV Export
Version Control	Git + GitHub
OS	Windows 11
🧱 Folder Structure
healthcare_membership_growth/
├── data/                     # Raw tables + exported view & KPI outputs
├── sql_views/                # 7 view creation scripts
├── sql_queries/              # 14 KPI SQL queries
├── powerbi/                  # PBIX dashboard
├── docs/                     # Insights & documentation
├── .gitignore
└── README.md

🤖 Modern Analytics Workflow & Use of AI

This project embraces a modern analytics workflow, where generative AI is used as an augmentation tool — similar to documentation, StackOverflow, or code templates.
Every SQL view, KPI definition, transformation, and insight was designed, validated, and reasoned manually, with AI used for:

drafting documentation

accelerating repetitive tasks

clarifying requirements

improving analytical explanations

AI accelerates productivity; it does not replace analytical thinking.
This reflects how contemporary data teams operate across healthcare, finance, B2B SaaS, and membership organizations.

© 2025 Victor King — Project for portfolio demonstration.
Licensed under the MIT License.
