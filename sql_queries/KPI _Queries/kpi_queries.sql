/* =========================================================
   KPI QUERIES - HEALTHCARE MEMBERSHIP GROWTH ANALYTICS
   All queries use the analytical views built in Phase 2.
   ========================================================= */

USE healthcare_membership_growth;
GO

/* ---------------------------------------------------------
   Q1. Channel funnel performance (from v_lead_funnel)
   --------------------------------------------------------- */

SELECT
    channel,
    COUNT(*) AS leads,
    SUM(CASE WHEN converted_flag = 1 THEN 1 ELSE 0 END) AS conversions,
    1.0 * SUM(CASE WHEN converted_flag = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS conversion_rate,
    AVG(CASE WHEN converted_flag = 1 THEN days_to_convert END) AS avg_days_to_convert
FROM dbo.v_lead_funnel
GROUP BY channel
ORDER BY leads DESC;
GO

/* ---------------------------------------------------------
   Q2. Lead source performance
   --------------------------------------------------------- */

SELECT
    lead_source,
    COUNT(*) AS leads,
    SUM(CASE WHEN converted_flag = 1 THEN 1 ELSE 0 END) AS conversions,
    1.0 * SUM(CASE WHEN converted_flag = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS conversion_rate
FROM dbo.v_lead_funnel
GROUP BY lead_source
ORDER BY leads DESC;
GO

/* ---------------------------------------------------------
   Q3. Time-to-convert by channel
   (simple distribution: min / avg / max)
   --------------------------------------------------------- */

SELECT
    channel,
    COUNT(*) AS converted_leads,
    MIN(days_to_convert) AS min_days_to_convert,
    AVG(days_to_convert) AS avg_days_to_convert,
    MAX(days_to_convert) AS max_days_to_convert
FROM dbo.v_lead_funnel
WHERE converted_flag = 1
GROUP BY channel
ORDER BY avg_days_to_convert;
GO

/* ---------------------------------------------------------
   Q4. Acquisition cohorts (members)
   --------------------------------------------------------- */

SELECT
    acquisition_cohort_ym,
    COUNT(*) AS members,
    SUM(CASE WHEN has_purchased_flag = 1 THEN 1 ELSE 0 END) AS members_purchased,
    SUM(CASE WHEN has_engaged_flag   = 1 THEN 1 ELSE 0 END) AS members_engaged,
    1.0 * SUM(CASE WHEN has_purchased_flag = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS purchase_rate,
    1.0 * SUM(CASE WHEN has_engaged_flag = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS engagement_rate
FROM dbo.v_member_cohort
GROUP BY acquisition_cohort_ym
ORDER BY acquisition_cohort_ym;
GO

/* =========================================================
   B. ENGAGEMENT & PRODUCT BEHAVIOR
   ========================================================= */

/* ---------------------------------------------------------
   Q5. Engagement by membership tier
   --------------------------------------------------------- */

SELECT
    membership_tier,
    COUNT(*) AS members,
    SUM(CASE WHEN total_events IS NOT NULL AND total_events > 0
             THEN 1 ELSE 0 END) AS engaged_members,
    AVG(ISNULL(total_events, 0.0)) AS avg_events_per_member
FROM dbo.v_member_event_engagement
GROUP BY membership_tier
ORDER BY members DESC;
GO

/* ---------------------------------------------------------
   Q6. Event mix by membership tier
   --------------------------------------------------------- */

SELECT
    membership_tier,
    AVG(ISNULL(course_events,      0.0)) AS avg_course_events,
    AVG(ISNULL(webinar_events,     0.0)) AS avg_webinar_events,
    AVG(ISNULL(dashboard_events,   0.0)) AS avg_dashboard_events,
    AVG(ISNULL(conference_events,  0.0)) AS avg_conference_events,
    AVG(ISNULL(resource_events,    0.0)) AS avg_resource_events
FROM dbo.v_member_event_engagement
GROUP BY membership_tier
ORDER BY membership_tier;
GO

/* ---------------------------------------------------------
   Q7. Purchasing by membership tier
   --------------------------------------------------------- */

SELECT
    membership_tier,
    COUNT(*) AS members,
    SUM(CASE WHEN total_spend IS NOT NULL AND total_spend > 0
             THEN 1 ELSE 0 END) AS purchasing_members,
    AVG(ISNULL(purchase_count, 0.0)) AS avg_purchase_count,
    AVG(ISNULL(total_spend,    0.0)) AS avg_total_spend
FROM dbo.v_member_purchase_history
GROUP BY membership_tier
ORDER BY members DESC;
GO

/* =========================================================
   C. CAMPAIGN PERFORMANCE
   ========================================================= */

/* ---------------------------------------------------------
   Q8. Campaign funnel + economics
   --------------------------------------------------------- */

-- KPI 8: Campaign Funnel Economics
-- What are the touch → lead → conversion → revenue economics per campaign?

SELECT
    cp.campaign_id,
    cp.campaign_name,
    cp.channel,
    cp.spend_amount,

    cp.touches,
    cp.leads,
    cp.conversions,
    cp.attributed_revenue,

    -- Cost metrics
    CASE 
        WHEN cp.touches = 0 THEN NULL
        ELSE cp.spend_amount * 1.0 / cp.touches 
    END AS cost_per_touch,

    CASE 
        WHEN cp.leads = 0 THEN NULL
        ELSE cp.spend_amount * 1.0 / cp.leads 
    END AS cost_per_lead,

    CASE 
        WHEN cp.conversions = 0 THEN NULL
        ELSE cp.spend_amount * 1.0 / cp.conversions 
    END AS cost_per_conversion,

    -- Revenue efficiency
    CASE 
        WHEN cp.spend_amount = 0 THEN NULL
        ELSE cp.attributed_revenue * 1.0 / cp.spend_amount
    END AS roi_multiplier

FROM dbo.v_campaign_performance AS cp
ORDER BY cp.campaign_id;


/* ---------------------------------------------------------
   Q9. Top 5 campaigns by revenue & ROI
   --------------------------------------------------------- */

SELECT TOP (5)
    campaign_id,
    campaign_name,
    channel,
    spend_amount,
    attributed_revenue,
    CASE
        WHEN spend_amount = 0 THEN NULL
        ELSE attributed_revenue / CAST(spend_amount AS decimal(18,2))
    END AS roi_revenue_to_spend
FROM dbo.v_campaign_performance
ORDER BY attributed_revenue DESC;
GO

/* ---------------------------------------------------------
   Q10. Active vs inactive campaign averages
   --------------------------------------------------------- */

WITH campaign_metrics AS (
    SELECT
        is_active,
        touches,
        leads,
        conversions,
        attributed_revenue,
        spend_amount,
        1.0 * conversions / NULLIF(leads, 0) AS conversion_rate,
        spend_amount / NULLIF(CAST(conversions AS decimal(18,2)), 0) AS cost_per_conversion,
        1.0 * attributed_revenue / NULLIF(leads, 0) AS revenue_per_lead
    FROM dbo.v_campaign_performance
)
SELECT
    is_active,
    COUNT(*) AS campaigns,
    AVG(conversion_rate)       AS avg_conversion_rate,
    AVG(cost_per_conversion)   AS avg_cost_per_conversion,
    AVG(revenue_per_lead)      AS avg_revenue_per_lead
FROM campaign_metrics
GROUP BY is_active
ORDER BY is_active DESC;
GO

/* =========================================================
   D. COHORTS, RETENTION, 360 VIEW
   ========================================================= */

/* ---------------------------------------------------------
   Q11. Retention by acquisition cohort
   --------------------------------------------------------- */

SELECT
    acquisition_cohort_ym,
    COUNT(*) AS members,
    SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) AS active_members,
    1.0 * SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0) AS retention_rate
FROM dbo.v_member_cohort
GROUP BY acquisition_cohort_ym
ORDER BY acquisition_cohort_ym;
GO

/* ---------------------------------------------------------
   Q12. Revenue per member by acquisition cohort
   --------------------------------------------------------- */

SELECT
    mc.acquisition_cohort_ym,
    COUNT(DISTINCT mc.member_id) AS members,
    SUM(ISNULL(ml.total_revenue_usd, 0.0)) AS total_revenue,
    1.0 * SUM(ISNULL(ml.total_revenue_usd, 0.0))
        / NULLIF(COUNT(DISTINCT mc.member_id), 0) AS avg_revenue_per_member
FROM dbo.v_member_cohort   AS mc
LEFT JOIN dbo.v_member_lifecycle AS ml
    ON mc.member_id = ml.member_id
GROUP BY mc.acquisition_cohort_ym
ORDER BY mc.acquisition_cohort_ym;
GO


/* ---------------------------------------------------------
   Q13. High / medium / low value segments
   (simple thresholding on total_spend)
   --------------------------------------------------------- */

-- This version uses a subquery so we can safely ORDER BY the alias.

SELECT
    t.value_segment,
    COUNT(*) AS members,
    AVG(ISNULL(t.total_spend, 0.0)) AS avg_spend
FROM (
    SELECT
        CASE
            WHEN total_spend >= 2000 THEN 'High value'
            WHEN total_spend >= 500  THEN 'Medium value'
            WHEN total_spend >  0    THEN 'Low value'
            ELSE 'No spend'
        END AS value_segment,
        total_spend
    FROM dbo.v_member_360
) AS t
GROUP BY
    t.value_segment
ORDER BY
    CASE t.value_segment
        WHEN 'High value'   THEN 1
        WHEN 'Medium value' THEN 2
        WHEN 'Low value'    THEN 3
        ELSE 4
    END;
GO


/* ---------------------------------------------------------
   Q14. Engagement vs revenue segments
   --------------------------------------------------------- */

-- Segment members into:
-- - High spend / high engagement
-- - High spend / low engagement
-- - Low spend / high engagement
-- - Low spend / low engagement

SELECT
    t.engagement_value_segment,
    COUNT(*) AS members,
    AVG(ISNULL(t.total_spend, 0.0))  AS avg_spend,
    AVG(ISNULL(t.total_events, 0.0)) AS avg_events
FROM (
    SELECT
        CASE
            WHEN total_spend >= 1000 AND total_events >= 20 THEN 'High spend / high engagement'
            WHEN total_spend >= 1000 AND total_events <  20 THEN 'High spend / low engagement'
            WHEN total_spend <  1000 AND total_events >= 20 THEN 'Low spend / high engagement'
            ELSE 'Low spend / low engagement'
        END AS engagement_value_segment,
        total_spend,
        total_events
    FROM dbo.v_member_360
) AS t
GROUP BY
    t.engagement_value_segment
ORDER BY
    CASE t.engagement_value_segment
        WHEN 'High spend / high engagement' THEN 1
        WHEN 'High spend / low engagement'  THEN 2
        WHEN 'Low spend / high engagement'  THEN 3
        ELSE 4
    END;
GO
