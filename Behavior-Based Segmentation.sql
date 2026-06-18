-- ============================================================
-- SQL 05: BEHAVIOR-BASED SEGMENTATION
-- Project: E-Commerce Conversion Intelligence
-- Dataset: Retail Rocket (Kaggle)
-- Tool: PostgreSQL
--
-- ⚠️ IMPORTANT NOTE:
-- This is NOT traditional RFM analysis.
-- This dataset contains no real monetary values.
-- We use behavioral engagement signals
-- as analytical proxy for user value.
--
-- RFE = Recency + Frequency + Engagement
-- (NOT Revenue — Engagement instead)
-- ============================================================


-- ============================================================
-- PART A: USER BASE METRICS
-- Calculate raw metrics per user
-- ============================================================

CREATE TABLE user_base_metrics AS
WITH
dataset_end AS (
SELECT MAX(event_datetime) AS max_date FROM master_clean_events)
SELECT
e.visitorid,
-- RECENCY: Days since last activity
EXTRACT(DAY FROM (d.max_date - MAX(e.event_datetime)))::INTEGER AS days_since_last_visit,
-- FREQUENCY: Total event count
COUNT(*) AS total_events,
-- Sessions
COUNT(DISTINCT e.session_id) AS total_sessions,
-- Event breakdown
SUM(CASE WHEN e.event_type = 'view' THEN 1 ELSE 0 END) AS total_views,
SUM(CASE WHEN e.event_type = 'addtocart' THEN 1 ELSE 0 END) AS total_carts,
-- ENGAGEMENT: Purchase count
SUM(CASE WHEN e.event_type = 'transaction' THEN 1 ELSE 0 END) AS total_purchases,
-- Unique items viewed
COUNT(DISTINCT e.itemid) AS unique_items_viewed,

-- First and last visit
MIN(e.event_datetime) AS first_visit,
MAX(e.event_datetime) AS last_visit

FROM master_clean_events e
CROSS JOIN dataset_end d
GROUP BY e.visitorid, d.max_date;

-- Check
SELECT COUNT(*) as total_users
FROM user_base_metrics;

SELECT * FROM user_base_metrics LIMIT 10;


-- ============================================================
-- PART B: RFE SCORING
-- Score each user 1-5 on each dimension
-- ============================================================

CREATE TABLE user_rfe_scores AS
SELECT
visitorid,
days_since_last_visit,
total_events,
total_sessions,
total_views,
total_carts,
total_purchases,
unique_items_viewed,
first_visit,
last_visit,

-- RECENCY SCORE (1-5)
-- Higher score = more recent
-- Lower days = more recent = higher score
-- So we REVERSE the NTILE

6 - NTILE(5) OVER (ORDER BY days_since_last_visit DESC)  AS recency_score,
-- FREQUENCY SCORE (1-5)
-- Higher score = more events
NTILE(5) OVER (ORDER BY total_events ASC) AS frequency_score,
-- ENGAGEMENT SCORE (1-5)
-- Higher score = more purchases
-- ⚠️ NOT monetary — behavioral proxy
NTILE(5) OVER (ORDER BY total_purchases ASC)AS engagement_score

FROM user_base_metrics;

-- Check
SELECT * FROM user_rfe_scores LIMIT 10;

-- Score distribution check
SELECT
recency_score,
COUNT(*) as user_count
FROM user_rfe_scores
GROUP BY recency_score
ORDER BY recency_score;


-- ============================================================
-- PART C: RFE COMBINED SCORE + SEGMENTS
-- ============================================================

CREATE TABLE user_segments AS
SELECT
visitorid,
days_since_last_visit,
total_events,
total_sessions,
total_views,
total_carts,
total_purchases,
unique_items_viewed,
first_visit,
last_visit,
recency_score,
frequency_score,
engagement_score,

-- Combined RFE Score (3-15)
recency_score + frequency_score + engagement_score AS rfe_score,

-- RFE SEGMENT
CASE
WHEN recency_score + frequency_score + engagement_score >= 13 THEN 'Power User'
WHEN recency_score + frequency_score +engagement_score >= 10 THEN 'Loyal Browser'
WHEN recency_score + frequency_score +engagement_score >= 7 THEN 'Occasional User'
WHEN recency_score + frequency_score + engagement_score >= 4 THEN 'Fading User'
ELSE 'Inactive'
END AS rfe_segment,

-- BEHAVIORAL LABEL
CASE
WHEN total_purchases >= 2 THEN 'Repeat Buyer'
WHEN total_purchases = 1 THEN 'One-time Buyer'
WHEN total_carts > 0 AND total_purchases = 0 THEN 'Cart Abandoner'
WHEN total_views >= 10 AND total_carts = 0 THEN 'Window Shopper'
ELSE 'Bounce User'
END AS behavioral_label

FROM user_rfe_scores;

-- Check
SELECT * FROM user_segments LIMIT 10;


-- ============================================================
-- PART D: SEGMENT SUMMARY
-- ============================================================

CREATE TABLE segment_summary AS
SELECT
rfe_segment,
behavioral_label,
COUNT(*) AS user_count,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS user_pct,
ROUND(AVG(total_events), 2) AS avg_events,
ROUND(AVG(total_sessions), 2) AS avg_sessions,
ROUND(AVG(total_views), 2) AS avg_views,
ROUND(AVG(total_carts), 2) AS avg_carts,
ROUND(AVG(total_purchases), 2) AS avg_purchases,
ROUND(AVG(rfe_score), 2) AS avg_rfe_score,
-- CVR per segment
ROUND(SUM(CASE WHEN total_purchases > 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS segment_cvr

FROM user_segments
GROUP BY rfe_segment, behavioral_label
ORDER BY avg_rfe_score DESC;

-- Check
SELECT * FROM segment_summary;


-- ============================================================
-- PART E: RFE SEGMENT ONLY SUMMARY
-- For Power BI Donut Chart
-- ============================================================

CREATE TABLE rfe_segment_summary AS
SELECT
rfe_segment,
COUNT(*)AS user_count,
ROUND(COUNT(*) * 100.0 /SUM(COUNT(*)) OVER (), 2)AS user_pct,
ROUND(AVG(total_events), 2)AS avg_events,
ROUND(AVG(total_sessions), 2)AS avg_sessions,
ROUND(AVG(total_purchases), 2)AS avg_purchases,
ROUND(AVG(rfe_score), 2)AS avg_rfe_score,
ROUND(SUM(CASE WHEN total_purchases > 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 2)AS segment_cvr

FROM user_segments
GROUP BY rfe_segment
ORDER BY avg_rfe_score DESC;

-- Check
SELECT * FROM rfe_segment_summary;


-- ============================================================
-- PART F: BEHAVIORAL LABEL SUMMARY
-- For Power BI Tree Map
-- ============================================================

CREATE TABLE behavioral_label_summary AS
SELECT
behavioral_label,
COUNT(*) AS user_count,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS user_pct,
ROUND(AVG(total_events), 2) AS avg_events,
ROUND(AVG(total_views), 2) AS avg_views,
ROUND(AVG(total_carts), 2) AS avg_carts,
ROUND(AVG(total_purchases), 2) AS avg_purchases,
ROUND(SUM(CASE WHEN total_purchases > 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS label_cvr

FROM user_segments
GROUP BY behavioral_label
ORDER BY user_count DESC;

-- Check
SELECT * FROM behavioral_label_summary;


-- ============================================================
-- PART G: COMBINED BEHAVIOR SEGMENTS FOR EXPORT
-- ============================================================

CREATE TABLE behavior_segments AS

-- RFE Segment Summary
SELECT
'rfe_segment' AS summary_type,
rfe_segment AS segment_name,
NULL AS behavioral_label,
user_count,
user_pct,
avg_events,
avg_sessions,
avg_purchases,
avg_rfe_score,
segment_cvr
FROM rfe_segment_summary

UNION ALL

-- Behavioral Label Summary
SELECT
'behavioral_label' AS summary_type,
behavioral_label AS segment_name,
behavioral_label,
user_count,
user_pct,
avg_events,
NULL AS avg_sessions,
avg_purchases,
NULL AS avg_rfe_score,
label_cvr AS segment_cvr
FROM behavioral_label_summary;
-- Check
SELECT * FROM behavior_segments;

-- ============================================================
-- EXPORT
-- ============================================================

COPY behavior_segments
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\behavior_segments.csv'
WITH (FORMAT CSV, HEADER TRUE);