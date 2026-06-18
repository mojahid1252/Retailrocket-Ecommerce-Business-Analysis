-- ============================================================
-- SQL 04: CART ABANDONMENT ANALYSIS
-- Project: E-Commerce Conversion Intelligence
-- Dataset: Retail Rocket (Kaggle)
-- Tool: PostgreSQL
--
-- Business Question:
-- What is the cart abandonment rate and
-- which users are most likely to abandon?
-- ============================================================

-- ============================================================
-- PART A: OVERALL CART ABANDONMENT
-- ============================================================

CREATE TABLE cart_abandonment_overall AS
WITH
user_cart_behavior AS (
SELECT
visitorid,
MAX(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) AS has_cart,
MAX(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) AS has_purchased
FROM master_clean_events
GROUP BY visitorid
)
SELECT
-- Total users who added to cart
SUM(CASE WHEN has_cart = 1 THEN 1 ELSE 0 END) AS total_cart_adders,
-- Total who purchased after cart
SUM(CASE WHEN has_cart = 1 AND has_purchased = 1 THEN 1 ELSE 0 END)AS cart_then_purchased,
-- Total who abandoned
SUM(CASE WHEN has_cart = 1 AND has_purchased = 0 THEN 1 ELSE 0 END) AS cart_abandoned,
-- Cart Abandonment Rate
ROUND(SUM(CASE WHEN has_cart = 1 AND has_purchased = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(SUM(CASE WHEN has_cart = 1
THEN 1 ELSE 0 END), 0), 2) AS abandonment_rate,
-- Cart to Purchase Rate
ROUND(SUM(CASE WHEN has_cart = 1 AND has_purchased = 1 THEN 1 ELSE 0 END) * 100.0 / NULLIF(SUM(CASE WHEN has_cart = 1
THEN 1 ELSE 0 END), 0), 2) AS cart_conversion_rate
FROM user_cart_behavior;
-- Check
SELECT * FROM cart_abandonment_overall;

-- ============================================================
-- PART B: ABANDONMENT BY USER BEHAVIOR
-- ============================================================

CREATE TABLE cart_abandonment_by_behavior AS
WITH
user_behavior AS (
SELECT
visitorid,
COUNT(DISTINCT session_id) AS session_count,
SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS view_count,
MAX(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) AS has_cart,
MAX(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) AS has_purchased,
MIN(event_datetime) AS first_visit,
MAX(event_datetime) AS last_visit
FROM master_clean_events
GROUP BY visitorid
),
-- Label users
labeled_users AS (
SELECT
*,
CASE WHEN session_count = 1 THEN 'Single Session' ELSE 'Multi Session' END AS session_type,
CASE WHEN view_count <= 3 THEN 'Light Viewer (1-3)' WHEN view_count <= 10 THEN 'Medium Viewer (4-10)'
ELSE 'Heavy Viewer (10+)' END AS viewer_type,
CASE WHEN session_count > 1 THEN 'Returning' ELSE 'New' END AS visitor_type
FROM user_behavior
WHERE has_cart = 1
)
-- By Session Type
SELECT
session_type,
COUNT(*) AS cart_users,
SUM(CASE WHEN has_purchased = 0 THEN 1 ELSE 0 END) AS abandoners,
ROUND(SUM(CASE WHEN has_purchased = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) , 2) AS abandonment_rate
FROM labeled_users
GROUP BY session_type

UNION ALL
-- By Viewer Type
SELECT
viewer_type AS session_type, 
COUNT(*) AS cart_users,
SUM(CASE WHEN has_purchased = 0 THEN 1 ELSE 0 END) AS abandoners,
ROUND(SUM(CASE WHEN has_purchased = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS abandonment_rate
FROM labeled_users
GROUP BY viewer_type

UNION ALL

-- By Visitor Type (New vs Returning)
SELECT
visitor_type AS session_type,
COUNT(*) AS cart_users,
SUM(CASE WHEN has_purchased = 0 THEN 1 ELSE 0 END) AS abandoners,
ROUND(SUM(CASE WHEN has_purchased = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS abandonment_rate
FROM labeled_users
GROUP BY visitor_type

ORDER BY abandonment_rate DESC;

-- Check
SELECT * FROM cart_abandonment_by_behavior;


-- ============================================================
-- PART C: ABANDONMENT BY TIME
-- ============================================================

CREATE TABLE cart_abandonment_by_time AS
WITH
session_cart AS (
SELECT
session_id,
visitorid,
hour_of_day,
day_of_week,
is_weekend,
MAX(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END)AS has_cart,
MAX(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END)AS has_purchased
FROM master_clean_events
GROUP BY session_id, visitorid,
hour_of_day, day_of_week, is_weekend
)
-- By Hour
SELECT
'hour' AS time_type,
hour_of_day::TEXT AS time_value,
COUNT(*) AS cart_sessions,
SUM(CASE WHEN has_cart = 1 AND has_purchased = 0 THEN 1 ELSE 0 END) AS abandoned_sessions,
ROUND(
    SUM(CASE WHEN has_cart = 1 AND has_purchased = 0 THEN 1 ELSE 0 END) * 100.0
    / NULLIF(SUM(CASE WHEN has_cart = 1 THEN 1 ELSE 0 END), 0),
    2
) AS abandonment_rate
FROM session_cart
WHERE has_cart = 1
GROUP BY hour_of_day

UNION ALL
-- By Day of Week
SELECT
'day_of_week' AS time_type,
CASE day_of_week
WHEN 0 THEN 'Sunday'
WHEN 1 THEN 'Monday'
WHEN 2 THEN 'Tuesday'
WHEN 3 THEN 'Wednesday'
WHEN 4 THEN 'Thursday'
WHEN 5 THEN 'Friday'
WHEN 6 THEN 'Saturday'
END AS time_value,
COUNT(*) AS cart_sessions,
SUM(CASE WHEN has_cart = 1 AND has_purchased = 0 THEN 1 ELSE 0 END) AS abandoned_sessions,
ROUND(SUM(CASE WHEN has_cart = 1 AND has_purchased = 0 THEN 1 ELSE 0 END) * 100.0 /
NULLIF(SUM(CASE WHEN has_cart = 1 THEN 1 ELSE 0 END), 0) , 2) AS abandonment_rate
FROM session_cart
WHERE has_cart = 1
GROUP BY day_of_week

UNION ALL
-- By Day Type
SELECT
'day_type' AS time_type,
CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS time_value,
COUNT(*) AS cart_sessions,
SUM(CASE WHEN has_cart = 1 AND has_purchased = 0 THEN 1 ELSE 0 END) AS abandoned_sessions,
ROUND(
SUM(CASE WHEN has_cart = 1 AND has_purchased = 0 THEN 1 ELSE 0 END) * 100.0
/ NULLIF(SUM(CASE WHEN has_cart = 1 THEN 1 ELSE 0 END), 0),2) AS abandonment_rate
FROM session_cart
WHERE has_cart = 1
GROUP BY is_weekend
ORDER BY time_type, abandonment_rate DESC;

-- Check
SELECT * FROM cart_abandonment_by_time;

-- ============================================================
-- PART D: ABANDONMENT BY PRODUCT
-- ============================================================

CREATE TABLE cart_abandonment_by_product AS
WITH
item_cart AS (
SELECT
itemid,
categoryid,
available,
session_id,
MAX(CASE WHEN event_type = 'addtocart'
THEN 1 ELSE 0 END) AS has_cart,
MAX(CASE WHEN event_type = 'transaction'
            THEN 1 ELSE 0 END) AS has_purchased
FROM master_clean_events
GROUP BY itemid, categoryid, available, session_id
)

SELECT
itemid,
categoryid,
available,
SUM(has_cart) AS total_cart_adds,
SUM(CASE WHEN has_cart = 1 AND has_purchased = 1 THEN 1 ELSE 0 END) AS purchased,
SUM(CASE WHEN has_cart = 1 AND has_purchased = 0 THEN 1 ELSE 0 END) AS abandoned,
ROUND(SUM(CASE WHEN has_cart = 1 AND has_purchased = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(SUM(has_cart), 0), 2) AS abandonment_rate
FROM item_cart
WHERE has_cart = 1
GROUP BY itemid, categoryid, available
ORDER BY abandoned DESC
LIMIT 20;

-- Check
SELECT * FROM cart_abandonment_by_product;


-- ============================================================
-- PART E: OUT OF STOCK ITEMS IN CART
-- ============================================================

CREATE TABLE outofstock_in_cart AS
SELECT
-- Total cart events
COUNT(*) AS total_cart_events,
-- Out of stock cart events
SUM(CASE WHEN available = 0 THEN 1 ELSE 0 END) AS outofstock_cart_events,
-- Available cart events
SUM(CASE WHEN available = 1 THEN 1 ELSE 0 END) AS available_cart_events,
-- Out of stock percentage
ROUND(SUM(CASE WHEN available = 0 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 2) AS outofstock_pct

FROM master_clean_events
WHERE event_type = 'addtocart';

-- Check
SELECT * FROM outofstock_in_cart;


-- ============================================================
-- PART F: TIME TO ABANDON
-- How long after cart add do users leave?
-- ============================================================

CREATE TABLE time_to_abandon AS
WITH
session_timeline AS (
SELECT
session_id,
visitorid,
MIN(CASE WHEN event_type = 'addtocart' THEN event_datetime END) AS first_cart_time,
MAX(event_datetime) AS last_event_time,
MAX(CASE WHEN event_type = 'transaction'
THEN 1 ELSE 0 END) AS has_purchased
FROM master_clean_events
GROUP BY session_id, visitorid
)

SELECT
ROUND(AVG(EXTRACT(EPOCH FROM
(last_event_time - first_cart_time)) / 60), 2) AS avg_mins_to_abandon,
ROUND( PERCENTILE_CONT(0.5) WITHIN GROUP (
ORDER BY EXTRACT(EPOCH FROM (last_event_time - first_cart_time)) / 60
)::numeric,2) AS median_mins_to_abandon,

MIN(EXTRACT(EPOCH FROM (last_event_time - first_cart_time)) / 60) AS min_mins,
MAX(EXTRACT(EPOCH FROM(last_event_time - first_cart_time)) / 60) AS max_mins

FROM session_timeline
WHERE first_cart_time IS NOT NULL AND has_purchased = 0;

-- Check
SELECT * FROM time_to_abandon;


-- ============================================================
-- PART G: ABANDONER PROFILE
-- ============================================================

CREATE TABLE abandoner_profile AS
WITH
user_behavior AS (
SELECT
visitorid,
COUNT(DISTINCT session_id) AS session_count,
SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS view_count,
SUM(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) AS cart_count,
MAX(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) AS has_cart,
MAX(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) AS has_purchased
FROM master_clean_events
GROUP BY visitorid
)

SELECT
-- Abandoner profile
ROUND(AVG(CASE WHEN has_cart = 1 AND has_purchased = 0 THEN view_count END) , 2) AS avg_views_before_abandon,
ROUND(AVG(CASE WHEN has_cart = 1 AND has_purchased = 0 THEN session_count END) , 2) AS avg_sessions_abandoners,
ROUND(AVG(CASE WHEN has_cart = 1 AND has_purchased = 0 THEN cart_count END), 2) AS avg_cart_adds_abandoners,

-- Buyer profile (for comparison)
ROUND(AVG(CASE WHEN has_purchased = 1 THEN view_count END) , 2) AS avg_views_buyers,
ROUND(AVG(CASE WHEN has_purchased = 1 THEN session_count END) , 2) AS avg_sessions_buyers,

-- Did abandoners ever return to purchase?
COUNT(DISTINCT CASE WHEN has_cart = 1 AND has_purchased = 0 AND session_count > 1
THEN visitorid END) AS abandoners_returned,
COUNT(DISTINCT CASE WHEN has_cart = 1 AND has_purchased = 0 THEN visitorid END) AS total_abandoners,

ROUND(COUNT(DISTINCT CASE WHEN has_cart = 1 AND has_purchased = 0 AND session_count > 1THEN visitorid END) * 100.0 /
NULLIF(COUNT(DISTINCT CASE WHEN has_cart = 1 AND has_purchased = 0 THEN visitorid END), 0), 2) AS pct_abandoners_returned

FROM user_behavior;

-- Check
SELECT * FROM abandoner_profile;


-- ============================================================
-- PART H: COMBINED CART ABANDONMENT FOR EXPORT
-- ============================================================

CREATE TABLE cart_abandonment AS
SELECT
'overall' AS analysis_type,
'all' AS segment,
total_cart_adders AS cart_users,
cart_abandoned AS abandoners,
abandonment_rate,
cart_conversion_rate
FROM cart_abandonment_overall

UNION ALL

SELECT
'behavior_segment' AS analysis_type,
session_type AS segment,
cart_users,
abandoners,
abandonment_rate,
ROUND(100 - abandonment_rate, 2) AS cart_conversion_rate
FROM cart_abandonment_by_behavior

UNION ALL

SELECT
'time_segment' AS analysis_type,
CONCAT(time_type, '_', time_value) AS segment,
cart_sessions AS cart_users,
abandoned_sessions AS abandoners,
abandonment_rate,
ROUND(100 - abandonment_rate, 2) AS cart_conversion_rate
FROM cart_abandonment_by_time;

-- Check
SELECT * FROM cart_abandonment;


-- ============================================================
-- EXPORT
-- ============================================================

COPY cart_abandonment
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\cart_abandonment .csv'
WITH (FORMAT CSV, HEADER TRUE);