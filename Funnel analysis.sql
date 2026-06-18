-- ============================================================
-- SQL 02: FUNNEL ANALYSIS
-- Project: E-Commerce Conversion Intelligence
-- Dataset: Retail Rocket (Kaggle)
-- Tool: PostgreSQL

-- Business Question:
-- Where exactly in the funnel are users dropping off?
-- ============================================================

-- ============================================================
-- PART A: OVERALL FUNNEL
-- ============================================================

CREATE TABLE funnel_overall AS
WITH
-- Count unique visitors at each stage
funnel_stages AS (
SELECT
COUNT(DISTINCT visitorid) AS total_visitors,
COUNT(DISTINCT CASE WHEN event_type = 'view' THEN visitorid END) AS viewers,
COUNT(DISTINCT CASE WHEN event_type = 'addtocart' THEN visitorid END) AS cart_adders,
COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN visitorid END) AS buyers

FROM master_clean_events)

SELECT
total_visitors,
viewers,
cart_adders,
buyers,
-- Conversion Rates
ROUND(viewers * 100.0 / total_visitors, 2) AS view_rate,
ROUND(cart_adders * 100.0 / viewers, 2) AS view_to_cart_rate,
ROUND(buyers * 100.0 / cart_adders, 2) AS cart_to_purchase_rate,
ROUND(buyers * 100.0 / total_visitors, 2) AS overall_cvr,
-- Drop-off Rates
ROUND((viewers - cart_adders) * 100.0 / viewers, 2) AS dropoff_view_to_cart,
ROUND((cart_adders - buyers) * 100.0 / cart_adders, 2) AS dropoff_cart_to_purchase

FROM funnel_stages;

-- Check
SELECT * FROM funnel_overall;


-- ============================================================
-- PART B: SESSION LEVEL FUNNEL
-- ============================================================

CREATE TABLE funnel_session AS
WITH
session_events AS (
SELECT
session_id,
MAX(CASE WHEN event_type = 'view'  THEN 1 ELSE 0 END) AS has_view,
MAX(CASE WHEN event_type = 'addtocart'  THEN 1 ELSE 0 END) AS has_cart,
MAX(CASE WHEN event_type = 'transaction'  THEN 1 ELSE 0 END) AS has_purchase
FROM master_clean_events
GROUP BY session_id )

SELECT
COUNT(*) AS total_sessions,
SUM(CASE WHEN has_view = 1 AND has_cart = 0 AND has_purchase = 0 THEN 1 ELSE 0 END) AS view_only_sessions,
SUM(CASE WHEN has_cart = 1 AND has_purchase = 0 THEN 1 ELSE 0 END) AS cart_no_purchase_sessions,
SUM(CASE WHEN has_purchase = 1 THEN 1 ELSE 0 END) AS purchase_sessions,
-- Session level CVR
ROUND(SUM(CASE WHEN has_purchase = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2)  AS session_cvr
FROM session_events;

-- Check
SELECT * FROM funnel_session;


-- ============================================================
-- PART C: FUNNEL BY HOUR OF DAY
-- ============================================================

CREATE TABLE funnel_by_hour AS
SELECT
hour_of_day,
COUNT(DISTINCT visitorid)AS total_visitors,
COUNT(DISTINCT CASE WHEN event_type = 'view' THEN visitorid END) AS viewers,
COUNT(DISTINCT CASE WHEN event_type = 'addtocart' THEN visitorid END) AS cart_adders,
COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN visitorid END) AS buyers,
ROUND(COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN visitorid END) * 100.0 / NULLIF(COUNT(DISTINCT visitorid), 0), 2)  AS cvr_by_hour

FROM master_clean_events
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- Check
SELECT * FROM funnel_by_hour;


-- ============================================================
-- PART D: FUNNEL BY DAY OF WEEK
-- ============================================================
CREATE TABLE funnel_by_day AS
SELECT
day_of_week,
CASE day_of_week
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
END AS day_name,

COUNT(DISTINCT visitorid) AS total_visitors,
COUNT(DISTINCT CASE WHEN event_type = 'view' THEN visitorid END) AS viewers,
COUNT(DISTINCT CASE WHEN event_type = 'addtocart' THEN visitorid END) AS cart_adders,
COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN visitorid END) AS buyers,
ROUND(COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN visitorid END) * 100.0 / NULLIF(COUNT(DISTINCT visitorid), 0), 2) AS cvr_by_day
FROM master_clean_events
GROUP BY day_of_week
ORDER BY day_of_week;

-- Check
SELECT * FROM funnel_by_day;


-- ============================================================
-- PART E: FUNNEL BY WEEKDAY VS WEEKEND
-- ============================================================
CREATE TABLE funnel_by_daytype AS
SELECT
CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
COUNT(DISTINCT visitorid) AS total_visitors,
COUNT(DISTINCT CASE WHEN event_type = 'view' THEN visitorid END) AS viewers,
COUNT(DISTINCT CASE WHEN event_type = 'addtocart' THEN visitorid END) AS cart_adders,
COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN visitorid END) AS buyers,
ROUND(COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN visitorid END) * 100.0 / NULLIF(COUNT(DISTINCT visitorid), 0), 2) AS cvr_by_daytype

FROM master_clean_events
GROUP BY is_weekend
ORDER BY is_weekend;

-- Check
SELECT * FROM funnel_by_daytype;


-- ============================================================
-- PART F: FUNNEL BY TOP 10 CATEGORIES
-- ============================================================
CREATE TABLE funnel_by_category AS
SELECT
categoryid,
COUNT(DISTINCT visitorid) AS total_visitors,
COUNT(DISTINCT CASE WHEN event_type = 'view' THEN visitorid END) AS viewers,
COUNT(DISTINCT CASE WHEN event_type = 'addtocart' THEN visitorid END) AS cart_adders,
COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN visitorid END) AS buyers,
ROUND(COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN visitorid END) * 100.0 / NULLIF(COUNT(DISTINCT visitorid), 0), 2) AS cvr_by_category

FROM master_clean_events
WHERE categoryid != -1
GROUP BY categoryid
ORDER BY total_visitors DESC
LIMIT 20;

-- Check
SELECT * FROM funnel_by_category;


-- ============================================================
-- PART G: COMBINED FUNNEL SUMMARY FOR EXPORT
-- ============================================================

CREATE TABLE funnel_summary AS

-- Overall funnel
SELECT
'overall' AS breakdown_type,
'all' AS breakdown_value,
total_visitors,
viewers,
cart_adders,
buyers,
view_rate,
view_to_cart_rate,
cart_to_purchase_rate,
overall_cvr AS cvr,
dropoff_view_to_cart,
dropoff_cart_to_purchase
FROM funnel_overall

UNION ALL

-- By hour
SELECT
'hour' AS breakdown_type,
hour_of_day::TEXT AS breakdown_value,
total_visitors,
viewers,
cart_adders,
buyers,
ROUND(viewers * 100.0 / NULLIF(total_visitors, 0), 2) AS view_rate,
ROUND(cart_adders * 100.0 / NULLIF(viewers, 0), 2) AS view_to_cart_rate,
ROUND(buyers * 100.0 / NULLIF(cart_adders, 0), 2) AS cart_to_purchase_rate,
cvr_by_hour AS cvr,
ROUND((viewers - cart_adders) * 100.0 / NULLIF(viewers, 0), 2) AS dropoff_view_to_cart,
ROUND((cart_adders - buyers) * 100.0 / NULLIF(cart_adders, 0), 2) AS dropoff_cart_to_purchase
FROM funnel_by_hour

UNION ALL

-- By day type
SELECT
'day_type' AS breakdown_type,
day_type AS breakdown_value,
total_visitors,
viewers,
cart_adders,
buyers,
ROUND(viewers * 100.0 / NULLIF(total_visitors, 0), 2) AS view_rate,
ROUND(cart_adders * 100.0 / NULLIF(viewers, 0), 2) AS view_to_cart_rate,
ROUND(buyers * 100.0 / NULLIF(cart_adders, 0), 2) AS cart_to_purchase_rate,
cvr_by_daytype AS cvr,
ROUND((viewers - cart_adders) * 100.0 / NULLIF(viewers, 0), 2) AS dropoff_view_to_cart,
ROUND((cart_adders - buyers) * 100.0 / NULLIF(cart_adders, 0), 2) AS dropoff_cart_to_purchase
FROM funnel_by_daytype;

-- Check
SELECT * FROM funnel_summary;

-- ============================================================
-- EXPORT
-- ============================================================

COPY funnel_summary
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\funnel_summary.csv'
WITH (FORMAT CSV, HEADER TRUE);






