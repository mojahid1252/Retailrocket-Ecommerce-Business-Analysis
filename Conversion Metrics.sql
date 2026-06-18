-- ============================================================
-- SQL 03: CONVERSION METRICS
-- Project: E-Commerce Conversion Intelligence
-- Dataset: Retail Rocket (Kaggle)
-- Tool: PostgreSQL
--
-- Business Question:
-- What are the core conversion metrics
-- across different segments?
-- ============================================================

-- ============================================================
-- PART A: OVERALL METRICS
-- ============================================================

CREATE TABLE conversion_overall AS
WITH
user_stats AS (
SELECT
visitorid,
COUNT(*) AS total_events,
SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS total_views,
SUM(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) AS total_carts,
SUM(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) AS total_purchases,
COUNT(DISTINCT session_id) AS total_sessions
FROM master_clean_events
GROUP BY visitorid
)

SELECT
-- Overall counts
COUNT(DISTINCT visitorid) AS total_visitors,
SUM(total_events) AS total_events,
SUM(total_views) AS total_views,
SUM(total_carts) AS total_carts,
SUM(total_purchases) AS total_purchases,

-- Overall CVR
ROUND(COUNT(DISTINCT CASE WHEN total_purchases > 0 THEN visitorid END) * 100.0 / COUNT(DISTINCT visitorid), 4) AS overall_cvr,
-- View to Cart Rate
ROUND(COUNT(DISTINCT CASE WHEN total_carts > 0 THEN visitorid END) * 100.0 / NULLIF(COUNT(DISTINCT CASE WHEN total_views > 0 THEN visitorid END), 0), 4)AS view_to_cart_rate,
-- Cart to Purchase Rate
ROUND(COUNT(DISTINCT CASE WHEN total_purchases > 0 THEN visitorid END) * 100.0 / NULLIF(COUNT(DISTINCT CASE WHEN total_carts > 0 THEN visitorid END), 0) , 4) AS cart_to_purchase_rate,
-- Avg events per user
ROUND(AVG(total_events), 2) AS avg_events_per_user,
-- Avg sessions per user
ROUND(AVG(total_sessions), 2) AS avg_sessions_per_user

FROM user_stats;
-- Check
SELECT * FROM conversion_overall;


-- ============================================================
-- PART B: CVR BY HOUR OF DAY
-- ============================================================

CREATE TABLE cvr_by_hour AS
WITH
user_hour AS (
SELECT
visitorid,
hour_of_day,
MAX(CASE WHEN event_type = 'transaction'THEN 1 ELSE 0 END) AS has_purchased
FROM master_clean_events
GROUP BY visitorid, hour_of_day
)

SELECT
hour_of_day,
COUNT(DISTINCT visitorid) AS total_visitors,
SUM(has_purchased) AS buyers,
ROUND(SUM(has_purchased) * 100.0 / NULLIF(COUNT(DISTINCT visitorid), 0), 4) AS cvr
FROM user_hour
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- Check
SELECT * FROM cvr_by_hour;


-- ============================================================
-- PART C: CVR BY DAY OF WEEK
-- ============================================================

CREATE TABLE cvr_by_day AS
WITH
user_day AS (
SELECT
visitorid,
day_of_week,
MAX(CASE WHEN event_type = 'transaction'THEN 1 ELSE 0 END) AS has_purchased
FROM master_clean_events
GROUP BY visitorid, day_of_week
)

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
COUNT(DISTINCT visitorid)AS total_visitors,
SUM(has_purchased)AS buyers,
ROUND(SUM(has_purchased) * 100.0 / NULLIF(COUNT(DISTINCT visitorid), 0) , 4)AS cvr
FROM user_day
GROUP BY day_of_week
ORDER BY day_of_week;

-- Check
SELECT * FROM cvr_by_day;


-- ============================================================
-- PART D: CVR WEEKDAY VS WEEKEND
-- ============================================================

CREATE TABLE cvr_by_daytype AS
WITH
user_daytype AS (
SELECT
visitorid,
is_weekend,
MAX(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END)AS has_purchased
FROM master_clean_events
GROUP BY visitorid, is_weekend
)

SELECT
CASE WHEN is_weekend = 1
THEN 'Weekend'
ELSE 'Weekday'
END AS day_type,
COUNT(DISTINCT visitorid) AS total_visitors,
SUM(has_purchased) AS buyers, 
ROUND(SUM(has_purchased) * 100.0 / NULLIF(COUNT(DISTINCT visitorid), 0)
, 4) AS cvr
FROM user_daytype
GROUP BY is_weekend
ORDER BY is_weekend;

-- Check
SELECT * FROM cvr_by_daytype;


-- ============================================================
-- PART E: CVR BY CATEGORY
-- ============================================================
CREATE TABLE cvr_by_category AS
WITH
user_category AS (
SELECT
visitorid,
categoryid,
MAX(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END)AS has_purchased
FROM master_clean_events
WHERE categoryid != -1
GROUP BY visitorid, categoryid
)

SELECT
categoryid,
COUNT(DISTINCT visitorid) AS total_visitors,
SUM(has_purchased) AS buyers,
ROUND(SUM(has_purchased) * 100.0 / NULLIF(COUNT(DISTINCT visitorid), 0), 4) AS cvr
FROM user_category
GROUP BY categoryid
ORDER BY total_visitors DESC
LIMIT 20;

-- Check
SELECT * FROM cvr_by_category;


-- ============================================================
-- PART F: CVR SINGLE VS MULTI SESSION
-- ============================================================

CREATE TABLE cvr_by_session_type AS
WITH
user_sessions AS (
SELECT
visitorid,
COUNT(DISTINCT session_id)AS session_count,
MAX(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END)AS has_purchased
FROM master_clean_events
GROUP BY visitorid
)

SELECT
CASE WHEN session_count = 1
THEN 'Single Session'
ELSE 'Multi Session'
END AS session_type,
COUNT(DISTINCT visitorid)AS total_visitors,
SUM(has_purchased)AS buyers,
ROUND(SUM(has_purchased) * 100.0 / NULLIF(COUNT(DISTINCT visitorid), 0), 4)AS cvr
FROM user_sessions
GROUP BY
CASE WHEN session_count = 1
THEN 'Single Session'
ELSE 'Multi Session'
END
ORDER BY cvr DESC;

-- Check
SELECT * FROM cvr_by_session_type;


-- ============================================================
-- PART G: PURCHASE PROBABILITY
-- ============================================================

CREATE TABLE purchase_probability AS
WITH
user_behavior AS (
SELECT
visitorid,
MAX(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END)AS has_cart,
MAX(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END)AS has_purchased,
COUNT(DISTINCT session_id)AS session_count,
SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END)AS view_count
FROM master_clean_events
GROUP BY visitorid
)

SELECT
-- P(purchase | has cart event)
ROUND(SUM(CASE WHEN has_cart = 1
AND has_purchased = 1 THEN 1 ELSE 0 END) * 100.0/ NULLIF(SUM(CASE WHEN has_cart = 1
THEN 1 ELSE 0 END), 0 4) AS p_purchase_given_cart,

-- P(purchase | viewed 3+ items)
ROUND(SUM(CASE WHEN view_count >= 3
AND has_purchased = 1
THEN 1 ELSE 0 END) * 100.0 /
NULLIF(SUM(CASE WHEN view_count >= 3
THEN 1 ELSE 0 END), 0)
, 4)AS p_purchase_given_3plus_views,

-- P(purchase | returned visitor)
ROUND(SUM(CASE WHEN session_count > 1
AND has_purchased = 1
THEN 1 ELSE 0 END) * 100.0 /
NULLIF(SUM(CASE WHEN session_count > 1
THEN 1 ELSE 0 END), 0)
, 4)AS p_purchase_given_return_visitor

FROM user_behavior;

-- Check
SELECT * FROM purchase_probability;


-- ============================================================
-- PART H: COMBINED CONVERSION METRICS FOR EXPORT
-- ============================================================

CREATE TABLE conversion_metrics AS

-- Overall metrics
SELECT
'overall' AS metric_type,
'all' AS metric_value,
total_visitors,
total_purchases AS buyers,
overall_cvr AS cvr,
avg_events_per_user,
avg_sessions_per_user
FROM conversion_overall

UNION ALL

-- By hour
SELECT
'hour' AS metric_type,
hour_of_day::TEXT AS metric_value,
total_visitors,
buyers,
cvr,
NULL AS avg_events_per_user,
NULL AS avg_sessions_per_user
FROM cvr_by_hour

UNION ALL

-- By day of week
SELECT
'day_of_week' AS metric_type,
day_name AS metric_value,
total_visitors,
buyers,
cvr,
NULL AS avg_events_per_user,
NULL AS avg_sessions_per_user
FROM cvr_by_day

UNION ALL

-- By day type
SELECT
'day_type' AS metric_type,
day_type AS metric_value,
total_visitors,
buyers,
cvr,
NULL AS avg_events_per_user,
NULL AS avg_sessions_per_user
FROM cvr_by_daytype

UNION ALL

-- By session type
SELECT
'session_type' AS metric_type,
session_type AS metric_value,
total_visitors,
buyers,
cvr,
NULL AS avg_events_per_user,
NULL AS avg_sessions_per_user
FROM cvr_by_session_type;

-- Check
SELECT * FROM conversion_metrics;


-- ============================================================
-- EXPORT
-- ============================================================

COPY conversion_metrics
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\conversion_metrics.csv'
WITH (FORMAT CSV, HEADER TRUE);


