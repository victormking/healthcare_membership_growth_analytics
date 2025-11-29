
-- View 1: v_lead_funnel
-- Purpose: Lead-level acquisition and conversion funnel enriched with organization & campaign context.
-- Note: conversion_date is NVARCHAR with values like 'NA', so we use TRY_CONVERT to avoid errors.

CREATE OR ALTER VIEW dbo.v_lead_funnel AS
SELECT
    l.lead_id,
    l.org_id,
    o.org_name,
    o.org_type,
    o.org_size_band,
    o.state,
    l.lead_source,
    l.campaign_id,
    c.campaign_name,
    c.channel,
    l.lead_created_date,                            -- already datetime2
    l.converted_flag,
    l.converted_member_id,
    TRY_CONVERT(datetime2, l.conversion_date) AS conversion_date,
    DATEDIFF(
        DAY,
        l.lead_created_date,
        TRY_CONVERT(datetime2, l.conversion_date)
    ) AS days_to_convert
FROM dbo.leads AS l
LEFT JOIN dbo.organizations AS o
    ON l.org_id = o.org_id
LEFT JOIN dbo.campaigns AS c
    ON l.campaign_id = c.campaign_id;
GO

----------------------------------------------------------------------
-- View 2: v_member_lifecycle
-- Purpose: Member-level lifecycle view combining org, engagement, and purchases.
----------------------------------------------------------------------

USE healthcare_membership_growth;
GO

/* View 2: v_member_lifecycle
   Purpose:
     Member-level lifecycle view combining:
       - membership info
       - org context
       - engagement events
       - product purchases
*/

CREATE OR ALTER VIEW dbo.v_member_lifecycle AS
WITH engagement AS (
    SELECT
        ee.member_id,
        MIN(ee.event_timestamp) AS first_event_ts,
        MAX(ee.event_timestamp) AS last_event_ts,
        COUNT(*)               AS total_events
    FROM dbo.engagement_events AS ee
    GROUP BY ee.member_id
),
purchases AS (
    SELECT
        ps.member_id,
        MIN(ps.purchase_timestamp) AS first_purchase_ts,
        MAX(ps.purchase_timestamp) AS last_purchase_ts,
        SUM(ps.price_usd)          AS total_revenue_usd,
        COUNT(*)                   AS order_count
    FROM dbo.product_sales AS ps
    GROUP BY ps.member_id
)
SELECT
    m.member_id,
    m.org_id,
    o.org_name,
    o.org_type,
    o.org_size_band,
    o.state,

    m.membership_tier,
    m.join_date,
    m.renewal_date,
    m.is_active,

    e.first_event_ts,
    e.last_event_ts,
    e.total_events,

    p.first_purchase_ts,
    p.last_purchase_ts,
    p.order_count,
    p.total_revenue_usd,

    -- Lifecycle metrics
    DATEDIFF(DAY, m.join_date, e.first_event_ts)      AS days_to_first_engagement,
    DATEDIFF(DAY, m.join_date, p.first_purchase_ts)  AS days_to_first_purchase,
    DATEDIFF(DAY, m.join_date, m.renewal_date)       AS planned_membership_days
FROM dbo.members AS m
LEFT JOIN dbo.organizations AS o
    ON m.org_id = o.org_id
LEFT JOIN engagement AS e
    ON m.member_id = e.member_id
LEFT JOIN purchases AS p
    ON m.member_id = p.member_id;
GO



/* View 3: v_member_cohort
   Purpose:
   - Assign each member to acquisition / renewal / first-purchase cohorts
   - Add lifecycle flags (engaged, purchased)
   - Add tenure metrics for cohort & retention analysis
*/

CREATE OR ALTER VIEW dbo.v_member_cohort AS
SELECT
      ml.member_id
    , ml.org_id
    , ml.org_name
    , ml.org_type
    , ml.org_size_band
    , ml.state
    , ml.membership_tier
    , ml.join_date
    , ml.renewal_date
    , ml.is_active

    -- Engagement & revenue from v_member_lifecycle
    , ml.first_event_ts
    , ml.last_event_ts
    , ml.total_events
    , ml.first_purchase_ts
    , ml.last_purchase_ts
    , ml.total_revenue_usd

    -- Cohort labels (YYYY-MM)
    , CONVERT(char(7), ml.join_date,          120) AS acquisition_cohort_ym
    , CONVERT(char(7), ml.renewal_date,       120) AS renewal_cohort_ym
    , CONVERT(char(7), ml.first_purchase_ts,  120) AS first_purchase_cohort_ym

    -- Lifecycle flags
    , CASE WHEN ml.total_events       > 0 THEN 1 ELSE 0 END AS has_engaged_flag
    , CASE WHEN ml.total_revenue_usd > 0 THEN 1 ELSE 0 END AS has_purchased_flag

    -- Tenure metrics
    , DATEDIFF(DAY, ml.join_date, ISNULL(ml.renewal_date, GETDATE())) AS tenure_days
    , DATEDIFF(DAY, ml.join_date, GETDATE())                          AS days_since_join
FROM dbo.v_member_lifecycle AS ml;
GO



/* View 4: v_campaign_performance
   Purpose:
   - Campaign → touches → leads → conversions → revenue
   - Aggregates all activity and outcomes at the campaign level
*/

CREATE OR ALTER VIEW dbo.v_campaign_performance AS
WITH lead_data AS (
    SELECT
        c.campaign_id,
        COUNT(DISTINCT l.lead_id) AS leads,
        SUM(CASE WHEN l.converted_flag = 1 THEN 1 ELSE 0 END) AS conversions
    FROM dbo.campaigns AS c
    LEFT JOIN dbo.leads AS l
        ON c.campaign_id = l.campaign_id
    GROUP BY c.campaign_id
),
touch_data AS (
    SELECT
        c.campaign_id,
        COUNT(*) AS touches
    FROM dbo.campaigns AS c
    LEFT JOIN dbo.campaign_touches AS t
        ON c.campaign_id = t.campaign_id
    GROUP BY c.campaign_id
),
revenue_data AS (
    SELECT
        c.campaign_id,
        SUM(ps.price_usd) AS attributed_revenue
    FROM dbo.campaigns AS c
    LEFT JOIN dbo.leads AS l
        ON c.campaign_id = l.campaign_id
       AND l.converted_flag = 1                                  -- only converted leads
    LEFT JOIN dbo.product_sales AS ps
        ON ps.member_id = TRY_CONVERT(int, l.converted_member_id) -- safely handle 'NA'
    GROUP BY c.campaign_id
)
SELECT
    c.campaign_id,
    c.campaign_name,
    c.channel,
    c.start_date,
    c.end_date,
    c.spend_amount,
    c.campaign_goal,
    c.is_active,

    td.touches,
    ld.leads,
    ld.conversions,
    rd.attributed_revenue
FROM dbo.campaigns AS c
LEFT JOIN touch_data   AS td ON c.campaign_id = td.campaign_id
LEFT JOIN lead_data    AS ld ON c.campaign_id = ld.campaign_id
LEFT JOIN revenue_data AS rd ON c.campaign_id = rd.campaign_id;
GO


/* View 5: v_member_event_engagement
   Purpose:
   - Summarize behavioral engagement patterns for each member.
   - Computes:
       first event date
       last event date
       total events
       course completions
       webinars attended
       dashboard views
       conferences attended
       resource downloads
   - Supports churn modeling & engagement scoring.
*/

CREATE OR ALTER VIEW dbo.v_member_event_engagement AS
WITH event_base AS (
    SELECT
        e.member_id,
        e.event_type,
        e.event_timestamp
    FROM dbo.engagement_events AS e
),

event_aggs AS (
    SELECT
        member_id,
        MIN(event_timestamp) AS first_event_ts,
        MAX(event_timestamp) AS last_event_ts,
        COUNT(*) AS total_events,

        SUM(CASE WHEN event_type LIKE '%Course%' THEN 1 ELSE 0 END) AS course_events,
        SUM(CASE WHEN event_type LIKE '%Webinar%' THEN 1 ELSE 0 END) AS webinar_events,
        SUM(CASE WHEN event_type LIKE '%Dashboard%' THEN 1 ELSE 0 END) AS dashboard_events,
        SUM(CASE WHEN event_type LIKE '%Conference%' THEN 1 ELSE 0 END) AS conference_events,
        SUM(CASE WHEN event_type LIKE '%Resource%' THEN 1 ELSE 0 END) AS resource_events

    FROM event_base
    GROUP BY member_id
)

SELECT
    m.member_id,
    m.org_id,
    m.first_name,
    m.last_name,
    m.role,
    m.membership_tier,
    m.join_date,
    m.renewal_date,
    m.is_active,

    ea.first_event_ts,
    ea.last_event_ts,
    ea.total_events,
    ea.course_events,
    ea.webinar_events,
    ea.dashboard_events,
    ea.conference_events,
    ea.resource_events

FROM dbo.members AS m
LEFT JOIN event_aggs AS ea
    ON m.member_id = ea.member_id;
GO




/* View 6: v_member_purchase_history
   Purpose:
   - Summarize monetary behavior for each member.
   - Computes:
        first purchase date
        last purchase date
        total spend
        number of purchases
        average order value
        most frequent product category
*/

CREATE OR ALTER VIEW dbo.v_member_purchase_history AS
WITH purchase_base AS (
    SELECT
        ps.member_id,
        ps.product_id,
        ps.purchase_timestamp,
        ps.price_usd,
        ps.product_name,
        ps.product_category
    FROM dbo.product_sales AS ps
),

purchase_aggs AS (
    SELECT
        member_id,
        MIN(purchase_timestamp) AS first_purchase_ts,
        MAX(purchase_timestamp) AS last_purchase_ts,
        COUNT(*) AS purchase_count,
        SUM(price_usd) AS total_spend,
        AVG(price_usd) AS avg_order_value
    FROM purchase_base
    GROUP BY member_id
),

category_mode AS (
    SELECT
        member_id,
        product_category,
        ROW_NUMBER() OVER (
            PARTITION BY member_id
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM purchase_base
    GROUP BY member_id, product_category
)

SELECT
    m.member_id,
    m.org_id,
    m.first_name,
    m.last_name,
    m.membership_tier,
    m.join_date,
    m.renewal_date,
    m.is_active,

    pa.first_purchase_ts,
    pa.last_purchase_ts,
    pa.purchase_count,
    pa.total_spend,
    pa.avg_order_value,

    cm.product_category AS top_product_category

FROM dbo.members AS m
LEFT JOIN purchase_aggs AS pa
    ON m.member_id = pa.member_id
LEFT JOIN category_mode AS cm
    ON m.member_id = cm.member_id
   AND cm.rn = 1;
GO



/* View 7: v_member_360
   Purpose:
   - Single customer view per member_id.
   - Combines demographic / org data, engagement behavior, and purchase behavior.
   - Built from:
       dbo.members
       dbo.organizations
       dbo.v_member_event_engagement
       dbo.v_member_purchase_history
*/

CREATE OR ALTER VIEW dbo.v_member_360 AS
SELECT
    -- Core identity / org context
    m.member_id,
    m.org_id,
    o.org_name,
    o.org_type,
    o.org_size_band,
    o.state,
    m.first_name,
    m.last_name,
    m.role,
    m.membership_tier,
    m.join_date,
    m.renewal_date,
    m.is_active,

    -- Engagement footprint (from v_member_event_engagement)
    mee.first_event_ts,
    mee.last_event_ts,
    mee.total_events,
    mee.course_events,
    mee.webinar_events,   -- removed article_views here

    -- Purchasing footprint (from v_member_purchase_history)
    mph.first_purchase_ts,
    mph.last_purchase_ts,
    mph.purchase_count,
    mph.total_spend,
    mph.avg_order_value,
    mph.top_product_category

FROM dbo.members AS m
LEFT JOIN dbo.organizations AS o
    ON m.org_id = o.org_id
LEFT JOIN dbo.v_member_event_engagement AS mee
    ON m.member_id = mee.member_id
LEFT JOIN dbo.v_member_purchase_history AS mph
    ON m.member_id = mph.member_id;
GO


