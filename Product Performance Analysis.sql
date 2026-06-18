-- ============================================================
-- SQL 06: PRODUCT PERFORMANCE ANALYSIS
-- Project: E-Commerce Conversion Intelligence
-- Dataset: Retail Rocket (Kaggle)
-- Tool: PostgreSQL
--
-- Business Question:
-- Which products get traffic but fail to convert?
-- ============================================================


-- ============================================================
-- PART A: PER ITEM METRICS
-- ============================================================

CREATE TABLE item_metrics AS
SELECT
itemid,
categoryid,
available,
-- Volume metrics
COUNT(*) AS total_events,
SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS total_views,
SUM(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) AS total_carts,
SUM(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) AS total_purchases,
-- Unique viewers
COUNT(DISTINCT visitorid) AS unique_viewers,
-- Conversion rates
ROUND(SUM(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) * 100.0
/ NULLIF(SUM(CASE WHEN event_type = 'view'THEN 1 ELSE 0 END), 0), 4) AS view_to_cart_rate,
ROUND(SUM(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) * 100.0 
/NULLIF(SUM(CASE WHEN event_type = 'addtocart'THEN 1 ELSE 0 END), 0), 4) AS cart_to_purchase_rate,
ROUND(SUM(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) * 100.0 
/ NULLIF(SUM(CASE WHEN event_type = 'view'THEN 1 ELSE 0 END), 0), 4) AS overall_item_cvr,
-- Cart abandonment per item
ROUND((SUM(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) - SUM(CASE WHEN event_type = 'transaction'
THEN 1 ELSE 0 END)) * 100.0 / NULLIF(SUM(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END), 0), 4) AS item_abandonment_rate

FROM master_clean_events
GROUP BY itemid, categoryid, available;
-- Check
SELECT COUNT(*) as total_items FROM item_metrics;
SELECT * FROM item_metrics
ORDER BY total_views DESC
LIMIT 10;


-- ============================================================
-- PART B: 4-QUADRANT CLASSIFICATION
-- ============================================================

CREATE TABLE item_quadrants AS
WITH
-- Calculate median values for quadrant split
medians AS (
SELECT
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_views)AS median_views,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY overall_item_cvr)AS median_cvr
FROM item_metrics
WHERE total_views > 0 AND overall_item_cvr > 0 
)
SELECT
m.itemid,
m.categoryid,
m.available,
m.total_views,
m.total_carts,
m.total_purchases,
m.unique_viewers,
m.view_to_cart_rate,
m.cart_to_purchase_rate,
m.overall_item_cvr,
m.item_abandonment_rate,
med.median_views,
med.median_cvr,
-- 4-Quadrant Classification
CASE WHEN m.total_views >= med.median_views AND m.overall_item_cvr >= med.median_cvr THEN 'Star Product'
WHEN m.total_views >= med.median_views AND m.overall_item_cvr < med.median_cvr THEN 'Traffic Waster'
WHEN m.total_views < med.median_views AND m.overall_item_cvr >= med.median_cvr THEN 'Hidden Gem'
ELSE 'Dead Product'
END AS product_quadrant

FROM item_metrics m
CROSS JOIN medians med
WHERE m.total_views > 0;
-- Check
SELECT * FROM item_quadrants LIMIT 10;

-- Quadrant distribution
SELECT
product_quadrant,
COUNT(*) AS item_count,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS item_pct,
ROUND(AVG(total_views), 2) AS avg_views,
ROUND(AVG(overall_item_cvr), 4) AS avg_cvr
FROM item_quadrants
GROUP BY product_quadrant
ORDER BY avg_views DESC;



-- ============================================================
-- PART C: PARETO ANALYSIS
-- Top 20% items = 80% of views?
-- ============================================================

CREATE TABLE pareto_analysis AS
WITH
-- Rank items by views
ranked_items AS (
SELECT
itemid,
total_views,
ROW_NUMBER() OVER (ORDER BY total_views DESC) AS view_rank,
COUNT(*) OVER () AS total_items,
SUM(total_views) OVER () AS grand_total_views
FROM item_metrics
WHERE total_views > 0
),
-- Calculate cumulative percentages
cumulative AS (
SELECT
itemid,
total_views,
view_rank,
total_items,
grand_total_views,
-- Item percentile
ROUND(view_rank * 100.0 / total_items, 2) AS item_pct,
-- Cumulative views
SUM(total_views) OVER (ORDER BY total_views DESC ROWS UNBOUNDED PRECEDING) AS cumulative_views
FROM ranked_items)

SELECT
itemid,
total_views,
view_rank,
item_pct,
cumulative_views,
grand_total_views,
-- Cumulative view percentage
ROUND(cumulative_views * 100.0 /grand_total_views, 2) AS cumulative_view_pct
FROM cumulative
ORDER BY view_rank;
-- Check top 20% items
SELECT
COUNT(*) AS top_20pct_items,
SUM(total_views) AS their_views,
ROUND(SUM(total_views) * 100.0 / MAX(grand_total_views), 2) AS pct_of_total_views
FROM pareto_analysis
WHERE item_pct <= 20;

SELECT * FROM pareto_analysis LIMIT 20;

-- ============================================================
-- PART D: OUT-OF-STOCK ANALYSIS
-- ============================================================
CREATE TABLE outofstock_analysis AS
SELECT
-- Overall out-of-stock traffic
SUM(CASE WHEN available = 0 THEN total_views ELSE 0 END) AS outofstock_views,
SUM(CASE WHEN available = 1 THEN total_views ELSE 0 END) AS available_views,
SUM(total_views) AS total_views,
-- Wasted traffic percentage
ROUND(SUM(CASE WHEN available = 0 THEN total_views ELSE 0 END) * 100.0 / NULLIF(SUM(total_views), 0) , 2) AS wasted_traffic_pct,
-- Out of stock items count
COUNT(DISTINCT CASE WHEN available = 0 THEN itemid END) AS outofstock_items,
-- Out of stock items in cart
SUM(CASE WHEN available = 0 THEN total_carts ELSE 0 END) AS outofstock_cart_adds

FROM item_metrics;

-- Check
SELECT * FROM outofstock_analysis;


-- ============================================================
-- PART E: CATEGORY LEVEL SUMMARY
-- Best + worst products per category
-- ============================================================

CREATE TABLE category_product_summary AS
WITH
category_stats AS (
SELECT
categoryid,
COUNT(DISTINCT itemid) AS total_items,
SUM(total_views) AS category_views,
SUM(total_purchases) AS category_purchases,
ROUND(AVG(overall_item_cvr), 4) AS avg_item_cvr,
MAX(overall_item_cvr) AS max_item_cvr,
MIN(overall_item_cvr) AS min_item_cvr,
-- Best product in category
MAX(total_views) AS max_views_in_category
FROM item_metrics
WHERE categoryid != -1
GROUP BY categoryid
)
SELECT
categoryid,
total_items,
category_views,
category_purchases,
avg_item_cvr,
max_item_cvr,
min_item_cvr,
max_views_in_category,
-- Category CVR
ROUND(category_purchases * 100.0 / NULLIF(category_views, 0) , 4) AS category_cvr

FROM category_stats
ORDER BY category_views DESC
LIMIT 20;

-- Check
SELECT * FROM category_product_summary;


-- ============================================================
-- PART F: TOP 10 BY VIEWS + TOP 10 BY CVR
-- ============================================================

-- Top 10 by views
SELECT
'top_by_views' AS rank_type,
itemid,
categoryid,
available,
total_views,
total_purchases,
overall_item_cvr,
product_quadrant
FROM item_quadrants
ORDER BY total_views DESC
LIMIT 10;

-- Top 10 by CVR (min 10 views filter)
SELECT
'top_by_cvr' AS rank_type,
itemid,
categoryid,
available,
total_views,
total_purchases,
overall_item_cvr,
product_quadrant
FROM item_quadrants
WHERE total_views >= 10
ORDER BY overall_item_cvr DESC
LIMIT 10;

-- Bottom 10 by CVR (min 10 views filter)
SELECT
'bottom_by_cvr' AS rank_type,
itemid,
categoryid,
available,
total_views,
total_purchases,
overall_item_cvr,
product_quadrant
FROM item_quadrants
WHERE total_views >= 10
ORDER BY overall_item_cvr ASC
LIMIT 10;


-- ============================================================
-- PART G: COMBINED PRODUCT PERFORMANCE FOR EXPORT
-- ============================================================

CREATE TABLE product_performance AS
SELECT
iq.itemid,
iq.categoryid,
iq.available,
iq.total_views,
iq.total_carts,
iq.total_purchases,
iq.unique_viewers,
iq.view_to_cart_rate,
iq.cart_to_purchase_rate,
iq.overall_item_cvr,
iq.item_abandonment_rate,
iq.product_quadrant,

-- Pareto rank
pa.view_rank,
pa.item_pct,
pa.cumulative_view_pct

FROM item_quadrants iq
LEFT JOIN pareto_analysis pa
ON iq.itemid = pa.itemid
ORDER BY iq.total_views DESC;

-- Check
SELECT * FROM product_performance ;

-- Quadrant count
SELECT
product_quadrant,
COUNT(*) AS item_count
FROM product_performance
GROUP BY product_quadrant
ORDER BY item_count DESC;


-- ============================================================
-- EXPORT
-- ============================================================

COPY product_performance
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\ product_performance.csv'
WITH (FORMAT CSV, HEADER TRUE)