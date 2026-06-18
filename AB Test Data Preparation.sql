-- ============================================================
-- SQL 10: A/B TEST DATA PREPARATION
-- Project: E-Commerce Conversion Intelligence
-- Dataset: Retail Rocket (Kaggle)
-- Tool: PostgreSQL
--
-- ⚠️ IMPORTANT DISCLAIMER:
-- These are NOT real controlled experiments.
-- No random user assignment was done during
-- data collection.
-- We simulate experiments using behavioral
-- and time-based user splits for analytical
-- demonstration purposes only.
-- This approach is standard in retrospective
-- e-commerce analysis.
-- ============================================================


-- ============================================================
-- PART A: USER BASE FOR AB TESTING
-- Build complete user profile first
-- ============================================================

CREATE TABLE ab_user_base AS
WITH
user_stats AS (
SELECT
visitorid,
-- Session info
COUNT(DISTINCT session_id) AS total_sessions,
COUNT(*) AS total_events,
-- Event counts
SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS total_views,
SUM(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) AS total_carts,
SUM(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) AS total_purchases,
-- Time features
-- Preferred hour = most common hour
MODE() WITHIN GROUP (ORDER BY hour_of_day) AS preferred_hour,
-- Majority day type
ROUND(AVG(is_weekend)) AS mostly_weekend,
-- Purchase flag
MAX(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) AS has_purchased,
-- Cart flag
MAX(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) AS has_cart

FROM master_clean_events
GROUP BY visitorid )
SELECT
visitorid,
total_sessions,
total_events,
total_views,
total_carts,
total_purchases,
preferred_hour,
mostly_weekend,
has_purchased,
has_cart,
-- Session type label
CASE WHEN total_sessions = 1 THEN 'Single Session' ELSE 'Multi Session' END AS session_type,
-- Viewer type label
CASE WHEN total_views >= 4 THEN 'Heavy Viewer' ELSE 'Light Viewer' END  AS viewer_type,
-- Time preference label
CASE WHEN preferred_hour BETWEEN 6 AND 11 THEN 'Morning' WHEN preferred_hour BETWEEN 18 AND 23 THEN 'Evening'
ELSE 'Other Time' END AS time_preference,
-- Day preference
CASE WHEN mostly_weekend >= 0.5 THEN 'Weekend' ELSE 'Weekday' END AS day_preference,
-- Cart abandoner flag
CASE WHEN has_cart = 1 AND has_purchased = 0 THEN 1 ELSE 0 END AS is_abandoner

FROM user_stats;

-- Check
SELECT COUNT(*) as total_users FROM ab_user_base;
SELECT * FROM ab_user_base LIMIT 10;


-- ============================================================
-- TEST 1: MORNING VS EVENING SHOPPERS
-- Group A (Control)  : 6am - 12pm users
-- Group B (Treatment): 6pm - 12am users
-- Metric: Conversion Rate
-- ============================================================

CREATE TABLE ab_test_1 AS
SELECT
'Test1_Morning_vs_Evening' AS test_name,
CASE WHEN time_preference = 'Morning' THEN 'Control_Morning'
WHEN time_preference = 'Evening' THEN 'Treatment_Evening' END AS group_label,
visitorid,
has_purchased AS converted,
total_events,
total_sessions

FROM ab_user_base
WHERE time_preference IN ('Morning', 'Evening');

-- Summary
SELECT
test_name,
group_label,
COUNT(*) AS total_users,
SUM(converted) AS total_conversions,
ROUND(SUM(converted) * 100.0 / NULLIF(COUNT(*), 0) , 4) AS conversion_rate
FROM ab_test_1
GROUP BY test_name, group_label
ORDER BY group_label;


-- ============================================================
-- TEST 2: SINGLE VS MULTI SESSION USERS
-- Group A (Control)  : 1 session users
-- Group B (Treatment): 2+ session users
-- Metric: Purchase Probability
-- ============================================================

CREATE TABLE ab_test_2 AS
SELECT
'Test2_Single_vs_MultiSession' AS test_name,
CASE WHEN session_type = 'Single Session' THEN 'Control_Single' ELSE 'Treatment_Multi' END AS group_label,
visitorid,
has_purchased AS converted,
total_sessions,
total_events

FROM ab_user_base;

-- Summary
SELECT
test_name,
group_label,
COUNT(*) AS total_users, 
SUM(converted) AS total_conversions,
ROUND(SUM(converted) * 100.0 / NULLIF(COUNT(*), 0), 4) AS conversion_rate
FROM ab_test_2
GROUP BY test_name, group_label
ORDER BY group_label;

-- ============================================================
-- TEST 3: WEEKDAY VS WEEKEND VISITORS
-- Group A (Control)  : Weekday visitors
-- Group B (Treatment): Weekend visitors
-- Metric: Conversion Rate
-- ============================================================

CREATE TABLE ab_test_3 AS
SELECT
'Test3_Weekday_vs_Weekend' AS test_name,
CASE WHEN day_preference = 'Weekday' THEN 'Control_Weekday' ELSE 'Treatment_Weekend' END AS group_label,
visitorid,
has_purchased AS converted,
total_events,
total_sessions

FROM ab_user_base;

-- Summary
SELECT
test_name,
group_label,
COUNT(*) AS total_users,
SUM(converted) AS total_conversions,
ROUND(SUM(converted) * 100.0 /NULLIF(COUNT(*), 0), 4) AS conversion_rate
FROM ab_test_3
GROUP BY test_name, group_label
ORDER BY group_label;

-- ============================================================
-- TEST 4: LIGHT VS HEAVY VIEWERS
-- Group A (Control)  : Viewed 1-3 items
-- Group B (Treatment): Viewed 4+ items
-- Metric: Cart + Purchase Rate
-- ============================================================



-- ============================================================
-- TEST 5: CART ABANDONERS — RETURN PATTERN
-- Group A: Abandoned, never returned
-- Group B: Abandoned, returned later
-- Metric: Final conversion rate
-- ============================================================

CREATE TABLE ab_test_5 AS
SELECT
'Test5_Abandoner_Return_Pattern' AS test_name,
CASE WHEN is_abandoner = 1 AND total_sessions = 1 THEN 'Control_Abandoned_NoReturn'
WHEN is_abandoner = 1 AND total_sessions > 1 THEN 'Treatment_Abandoned_Returned'
END AS group_label,

visitorid,
has_purchased AS converted,
total_sessions,
total_events,
total_carts

FROM ab_user_base
WHERE is_abandoner = 1;

-- Summary
SELECT
test_name,
group_label,
COUNT(*) AS total_users,
SUM(converted) AS total_conversions,
ROUND(SUM(converted) * 100.0 / NULLIF(COUNT(*), 0), 4) AS conversion_rate
FROM ab_test_5
GROUP BY test_name, group_label
ORDER BY group_label;


-- ============================================================
-- PART B: COMBINED AB TEST SUMMARY TABLE
-- This goes to Python for statistical testing
-- ============================================================

CREATE TABLE simulated_ab_groups AS

-- Test 1
SELECT
test_name,
group_label,
COUNT(*) AS total_users,
SUM(converted) AS total_conversions, 
ROUND(SUM(converted) * 100.0 / NULLIF(COUNT(*), 0), 4) AS conversion_rate
FROM ab_test_1
WHERE group_label IS NOT NULL
GROUP BY test_name, group_label

UNION ALL

-- Test 2
SELECT
test_name,
group_label,
COUNT(*) AS total_users,
SUM(converted)AS total_conversions,
ROUND(SUM(converted) * 100.0 / NULLIF(COUNT(*), 0), 4) AS conversion_rate
FROM ab_test_2
WHERE group_label IS NOT NULL
GROUP BY test_name, group_label

UNION ALL

-- Test 3
SELECT
test_name,
group_label,
COUNT(*) AS total_users,
SUM(converted) AS total_conversions,
ROUND(SUM(converted) * 100.0 / NULLIF(COUNT(*), 0), 4) AS conversion_rate
FROM ab_test_3
WHERE group_label IS NOT NULL
GROUP BY test_name, group_label

UNION ALL

-- Test 4
SELECT
test_name,
group_label,
COUNT(*) AS total_users,
SUM(converted) AS total_conversions,
ROUND(SUM(converted) * 100.0 /NULLIF(COUNT(*), 0), 4) AS conversion_rate
FROM ab_test_4
WHERE group_label IS NOT NULL
GROUP BY test_name, group_label

UNION ALL

-- Test 5
SELECT
test_name,
group_label,
COUNT(*) AS total_users,
SUM(converted) AS total_conversions,
ROUND(SUM(converted) * 100.0 / NULLIF(COUNT(*), 0), 4) AS conversion_rate
FROM ab_test_5
WHERE group_label IS NOT NULL
GROUP BY test_name, group_label

ORDER BY test_name, group_label;

-- Final Check
SELECT * FROM simulated_ab_groups;


-- ============================================================
-- PART C: HYPOTHESIS TEST DATA
-- For Python Notebook 03
-- ============================================================

CREATE TABLE hypothesis_test_data AS
WITH
user_full AS (
SELECT
e.visitorid,
COUNT(DISTINCT e.session_id)AS total_sessions,
COUNT(*)AS total_events,
SUM(CASE WHEN e.event_type = 'view' THEN 1 ELSE 0 END)AS total_views,
SUM(CASE WHEN e.event_type = 'addtocart' THEN 1 ELSE 0 END)AS total_carts,
SUM(CASE WHEN e.event_type = 'transaction' THEN 1 ELSE 0 END)AS total_purchases,
MAX(CASE WHEN e.event_type = 'transaction' THEN 1 ELSE 0 END)AS has_purchased,
MAX(CASE WHEN e.event_type = 'addtocart' THEN 1 ELSE 0 END)AS has_cart,
e.hour_of_day,
e.day_of_week,
e.is_weekend,
-- Session depth
COUNT(*) / NULLIF(COUNT(DISTINCT e.session_id), 0) AS avg_session_depth,
-- User category
e.categoryid
FROM master_clean_events e
GROUP BY e.visitorid, e.hour_of_day, e.day_of_week, e.is_weekend, e.categoryid)

SELECT
visitorid,
total_sessions,
total_events,
total_views,
total_carts,
total_purchases,
has_purchased,
has_cart,
hour_of_day,
day_of_week,
is_weekend,
avg_session_depth,
categoryid,

-- Labels for hypothesis tests
-- For T-Test (Test 1)
CASE WHEN has_purchased = 1 THEN 'Buyer' ELSE 'Non-Buyer' END AS buyer_label,

-- For Chi-Square (Test 2)
CASE 
WHEN hour_of_day BETWEEN 6 AND 11 THEN 'Morning'
WHEN hour_of_day BETWEEN 12 AND 17 THEN 'Afternoon'
WHEN hour_of_day BETWEEN 18 AND 23 THEN 'Evening'
ELSE 'Night'
END AS time_of_day_label,

-- For Z-Test (Test 3)
CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type_label,

-- For Mann-Whitney (Test 4)
avg_session_depth AS session_depth_score
FROM user_full;

-- Check
SELECT COUNT(*) as total_records
FROM hypothesis_test_data;

SELECT * FROM hypothesis_test_data LIMIT 10;

-- Distribution check
SELECT
buyer_label,
COUNT(*) AS count,
ROUND(AVG(total_views), 2) AS avg_views,
ROUND(AVG(avg_session_depth), 2) AS avg_session_depth
FROM hypothesis_test_data
GROUP BY buyer_label;


-- ============================================================
-- EXPORT ALL FILES
-- ============================================================

-- Main AB test groups for Python
COPY simulated_ab_groups
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\simulated_ab_groups.csv'
WITH (FORMAT CSV, HEADER TRUE);

-- Hypothesis test data for Python
COPY hypothesis_test_data
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\hypothesis_test_data.csv'
WITH (FORMAT CSV, HEADER TRUE);

-- Individual test details
COPY ab_test_1
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\ab_test_1.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY ab_test_2
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\ab_test_2.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY ab_test_3
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\ab_test_3.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY ab_test_4
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\ab_test_4.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY ab_test_5
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\ab_test_5.csv'
WITH (FORMAT CSV, HEADER TRUE);