-- ============================================================
-- SQL 09: CATEGORY ANALYSIS
-- Project: E-Commerce Conversion Intelligence
-- Dataset: Retail Rocket (Kaggle)
-- Tool: PostgreSQL
--
-- Business Question:
-- Which categories perform best/worst?
-- How does category hierarchy affect conversion?
-- ============================================================


-- ============================================================
-- PART A: CATEGORY TREE HIERARCHY
-- ============================================================

CREATE TABLE category_hierarchy AS
WITH RECURSIVE
-- Start with root categories (parentid is NULL)
category_tree AS (

-- Base case: root categories
SELECT
categoryid,
parentid,
categoryid AS root_category,
0 AS depth_level,
categoryid::TEXT AS path

FROM raw_category_tree
WHERE parentid IS NULL

UNION ALL

-- Recursive case: child categories
SELECT
c.categoryid,
c.parentid,
ct.root_category,
ct.depth_level + 1 AS depth_level,
ct.path || ' > ' || c.categoryid::TEXT AS path
FROM raw_category_tree c
JOIN category_tree ct
ON c.parentid = ct.categoryid
)
SELECT
categoryid,
parentid,
root_category,
depth_level,
path,
-- Is root category?
CASE WHEN parentid IS NULL THEN 1 ELSE 0 END AS is_root,
-- Is leaf category? (no children)
CASE WHEN categoryid NOT IN 
(SELECT DISTINCT parentid FROM raw_category_tree WHERE parentid IS NOT NULL)THEN 1 ELSE 0 END AS is_leaf

FROM category_tree;

-- Check
SELECT COUNT(*) as total_categories
FROM category_hierarchy;

-- Depth distribution
SELECT
depth_level,
COUNT(*) AS category_count
FROM category_hierarchy
GROUP BY depth_level
ORDER BY depth_level;

-- Root categories
SELECT *
FROM category_hierarchy
WHERE is_root = 1;


-- ============================================================
-- PART B: PER CATEGORY METRICS
-- ============================================================

CREATE TABLE category_metrics AS
SELECT
e.categoryid,
-- Event counts
COUNT(*) AS total_events,
SUM(CASE WHEN e.event_type = 'view' THEN 1 ELSE 0 END) AS total_views,
SUM(CASE WHEN e.event_type = 'addtocart' THEN 1 ELSE 0 END) AS total_carts,
SUM(CASE WHEN e.event_type = 'transaction' THEN 1 ELSE 0 END) AS total_purchases,
-- Unique visitors
COUNT(DISTINCT e.visitorid) AS unique_visitors,
-- Unique items
COUNT(DISTINCT e.itemid) AS unique_items,
-- Conversion rates
ROUND(SUM(CASE WHEN e.event_type = 'addtocart' THEN 1 ELSE 0 END) * 100.0 /
NULLIF(SUM(CASE WHEN e.event_type = 'view' THEN 1 ELSE 0 END), 0), 4) AS view_to_cart_rate,

ROUND(
SUM(CASE WHEN e.event_type = 'transaction' THEN 1 ELSE 0 END) * 100.0 /
NULLIF(SUM(CASE WHEN e.event_type = 'addtocart' THEN 1 ELSE 0 END), 0), 4) AS cart_to_purchase_rate,

ROUND(
SUM(CASE WHEN e.event_type = 'transaction' THEN 1 ELSE 0 END) * 100.0 /
NULLIF(SUM(CASE WHEN e.event_type = 'view' THEN 1 ELSE 0 END), 0), 4) AS category_cvr,

-- Cart abandonment rate
ROUND((SUM(CASE WHEN e.event_type = 'addtocart' THEN 1 ELSE 0 END) -SUM(CASE WHEN e.event_type = 'transaction'
THEN 1 ELSE 0 END)) * 100.0 /
NULLIF(SUM(CASE WHEN e.event_type = 'addtocart' THEN 1 ELSE 0 END), 0) , 4) AS cart_abandonment_rate,
-- Out of stock items
COUNT(DISTINCT CASE WHEN e.available = 0 THEN e.itemid END) AS outofstock_items,
-- Out of stock views
SUM(CASE WHEN e.available = 0 AND e.event_type = 'view' THEN 1 ELSE 0 END) AS outofstock_views

FROM master_clean_events e
WHERE e.categoryid != -1
GROUP BY e.categoryid;

-- Check
SELECT COUNT(*) as total_categories
FROM category_metrics;

SELECT * FROM category_metrics
ORDER BY total_views DESC
LIMIT 10;


-- ============================================================
-- PART C: JOIN CATEGORY METRICS WITH HIERARCHY
-- ============================================================

CREATE TABLE category_full AS
SELECT
cm
ch.parentid,
ch.root_category,
ch.depth_level,
ch.path,
ch.is_root,
ch.is_leaf

FROM category_metrics cm
LEFT JOIN category_hierarchy ch
ON cm.categoryid = ch.categoryid;

-- Check
SELECT * FROM category_full
ORDER BY total_views DESC
LIMIT 10;


-- ============================================================
-- PART D: TOP 10 BY TRAFFIC
-- ============================================================

CREATE TABLE top_categories_by_traffic AS
SELECT
categoryid,
total_views,
total_purchases,
unique_visitors,
unique_items,
category_cvr,
cart_abandonment_rate,
depth_level,
path,
RANK() OVER (ORDER BY total_views DESC) AS traffic_rank

FROM category_full
ORDER BY total_views DESC
LIMIT 10;

-- Check
SELECT * FROM top_categories_by_traffic;


-- ============================================================
-- PART E: TOP 10 BY CONVERSION RATE
-- Min 100 views filter for reliability
-- ============================================================

CREATE TABLE top_categories_by_cvr AS
SELECT
categoryid,
total_views,
total_purchases,
unique_visitors,
category_cvr,
cart_abandonment_rate,
depth_level,
path,
RANK() OVER (ORDER BY category_cvr DESC) AS cvr_rank

FROM category_full
WHERE total_views >= 100
ORDER BY category_cvr DESC
LIMIT 10;

-- Check
SELECT * FROM top_categories_by_cvr;


-- ============================================================
-- PART F: WORST 10 BY CVR
-- Min 100 views filter for reliability
-- ============================================================

CREATE TABLE worst_categories_by_cvr AS
SELECT
categoryid,
total_views,
total_purchases,
unique_visitors,
category_cvr,
cart_abandonment_rate,
depth_level,
path,
RANK() OVER (ORDER BY category_cvr ASC) AS worst_cvr_rank

FROM category_full
WHERE total_views >= 100
ORDER BY category_cvr ASC
LIMIT 10;

-- Check
SELECT * FROM worst_categories_by_cvr;
-- ============================================================
-- PART G: ROOT CATEGORY SUMMARY
-- Performance by top-level categories
-- ============================================================

CREATE TABLE root_category_summary AS
SELECT
cf.root_category,
COUNT(DISTINCT cf.categoryid) AS subcategory_count,
SUM(cf.total_views) AS total_views,
SUM(cf.total_carts) AS total_carts,
SUM(cf.total_purchases) AS total_purchases,
COUNT(DISTINCT cf.unique_visitors) AS unique_visitors,

-- Root category CVR
ROUND(SUM(cf.total_purchases) * 100.0 / NULLIF(SUM(cf.total_views), 0), 4) AS root_cvr,
-- Root cart abandonment
ROUND((SUM(cf.total_carts) - SUM(cf.total_purchases)) * 100.0 / NULLIF(SUM(cf.total_carts), 0), 4) AS root_abandonment_rate

FROM category_full cf
GROUP BY cf.root_category
ORDER BY total_views DESC
LIMIT 15;

-- Check
SELECT * FROM root_category_summary;


-- ============================================================
-- PART H: CROSS CATEGORY BROWSING
-- Users who viewed category A also viewed category B
-- ============================================================

CREATE TABLE cross_category_browsing AS
WITH
-- Get user-category pairs
user_categories AS (
SELECT DISTINCT
visitorid,
categoryid
FROM master_clean_events
WHERE categoryid != -1
AND event_type = 'view'
),

-- Self join to find co-browsing pairs
category_pairs AS (
SELECT
a.categoryid AS category_a,
b.categoryid AS category_b,
COUNT(DISTINCT a.visitorid) AS shared_users
FROM user_categories a
JOIN user_categories b
ON a.visitorid = b.visitorid
AND a.categoryid < b.categoryid
GROUP BY a.categoryid, b.categoryid
HAVING COUNT(DISTINCT a.visitorid) >= 100)

SELECT
category_a,
category_b,
shared_users,
RANK() OVER (ORDER BY shared_users DESC) AS pair_rank

FROM category_pairs
ORDER BY shared_users DESC
LIMIT 20;

-- Check
SELECT * FROM cross_category_browsing;


-- ============================================================
-- PART I: MOST VIEWED ITEMS PER CATEGORY
-- ============================================================

CREATE TABLE top_items_per_category AS
WITH
item_category_views AS (
SELECT
categoryid,
itemid,
COUNT(*) AS item_views,
SUM(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) AS item_purchases,
ROUND(SUM(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0), 4) AS item_cvr,
ROW_NUMBER() OVER (PARTITION BY categoryid ORDER BY COUNT(*) DESC) AS item_rank_in_category

FROM master_clean_events
WHERE categoryid != -1
GROUP BY categoryid, itemid
)

SELECT *
FROM item_category_views
WHERE item_rank_in_category <= 3
ORDER BY categoryid, item_rank_in_category;

-- Check
SELECT * FROM top_items_per_category LIMIT 20;


-- ============================================================
-- PART J: COMBINED CATEGORY ANALYSIS FOR EXPORT
-- ============================================================

CREATE TABLE category_analysis AS
SELECT
cf.categoryid,
cf.parentid,
cf.root_category,
cf.depth_level,
cf.path,
cf.is_root,
cf.is_leaf,
cf.total_views,
cf.total_carts,
cf.total_purchases,
cf.unique_visitors,
cf.unique_items,
cf.view_to_cart_rate,
cf.cart_to_purchase_rate,
cf.category_cvr,
cf.cart_abandonment_rate,
cf.outofstock_items,
cf.outofstock_views,
-- Traffic rank
RANK() OVER (ORDER BY cf.total_views DESC) AS traffic_rank,
-- CVR rank (min 100 views)
RANK() OVER (ORDER BY CASE WHEN cf.total_views >= 100 THEN cf.category_cvr ELSE NULL END DESC NULLS LAST) AS cvr_rank

FROM category_full cf
ORDER BY cf.total_views DESC;

-- Check
SELECT * FROM category_analysis LIMIT 10;

SELECT COUNT(*) as total_categories
FROM category_analysis;


-- ============================================================
-- EXPORT
-- ============================================================

COPY category_analysis
TO 'C:\temp\category_analysis.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY cross_category_browsing
TO 'C:\temp\cross_category_browsing.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY root_category_summary
TO 'C:\temp\root_category_summary.csv'
WITH (FORMAT CSV, HEADER TRUE);