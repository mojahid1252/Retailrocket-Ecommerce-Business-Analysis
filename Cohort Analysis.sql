-- ============================================================
-- SQL 07: COHORT ANALYSIS
-- Project: E-Commerce Conversion Intelligence
-- Dataset: Retail Rocket (Kaggle)
-- Tool: PostgreSQL
--
-- Business Question:
-- How well do we retain users over time?
-- Which cohorts have the best retention?
-- ============================================================


-- ============================================================
-- PART A: USER FIRST ACTIVITY MONTH
-- Define cohorts based on first visit month
-- ============================================================

CREATE TABLE user_cohorts AS
SELECT
visitorid,
-- First activity month = cohort
DATE_TRUNC('month',MIN(event_datetime)) AS cohort_month,
-- First activity date
MIN(event_datetime) AS first_visit,
-- Last activity date
MAX(event_datetime) AS last_visit,
-- Total purchases
SUM(CASE WHEN event_type = 'transaction'THEN 1 ELSE 0 END) AS total_purchases,
-- Has purchased ever
MAX(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) AS has_purchased

FROM master_clean_events
GROUP BY visitorid;

-- Check
SELECT COUNT(*) as total_users FROM user_cohorts;

SELECT * FROM user_cohorts;
-- Cohort sizes
SELECT
cohort_month,
COUNT(*) AS cohort_size
FROM user_cohorts
GROUP BY cohort_month
ORDER BY cohort_month;


-- ============================================================
-- PART B: ACTIVITY PER USER PER MONTH
-- Track when each user was active
-- ============================================================

CREATE TABLE user_monthly_activity AS
SELECT
visitorid,
DATE_TRUNC('month', event_datetime) AS activity_month
FROM master_clean_events
GROUP BY visitorid,
DATE_TRUNC('month', event_datetime);

-- Check
SELECT COUNT(*) as total_records
FROM user_monthly_activity;

SELECT * FROM user_monthly_activity LIMIT 10;


-- ============================================================
-- PART C: RETENTION MATRIX
-- Month 0 = cohort month
-- Month 1 = 1 month after cohort
-- etc.
-- ============================================================

CREATE TABLE cohort_retention_matrix AS
WITH
-- Join cohort info with activity
cohort_activity AS (
SELECT
uc.visitorid,
uc.cohort_month,
uma.activity_month,
-- Month number (0 = cohort month)
EXTRACT(YEAR FROM AGE(uma.activity_month,uc.cohort_month)) * 12 +
EXTRACT(MONTH FROM AGE(uma.activity_month,uc.cohort_month)) AS month_number

FROM user_cohorts uc
JOIN user_monthly_activity uma
ON uc.visitorid = uma.visitorid
WHERE uma.activity_month >= uc.cohort_month
),
-- Count users per cohort per month
cohort_counts AS (
SELECT
cohort_month,
month_number,
COUNT(DISTINCT visitorid) AS active_users
FROM cohort_activity
GROUP BY cohort_month, month_number
),
-- Get cohort sizes (Month 0)
cohort_sizes AS (
SELECT
cohort_month,
active_users AS cohort_size
FROM cohort_counts
WHERE month_number = 0
)

SELECT
cc.cohort_month,
cc.month_number,
cc.active_users,
cs.cohort_size,
-- Retention percentage
ROUND(cc.active_users * 100.0 /NULLIF(cs.cohort_size, 0), 2) AS retention_pct

FROM cohort_counts cc
JOIN cohort_sizes cs
ON cc.cohort_month = cs.cohort_month
ORDER BY cc.cohort_month, cc.month_number;

-- Check
SELECT * FROM cohort_retention_matrix;


-- ============================================================
-- PART D: PIVOT RETENTION MATRIX
-- Rows = Cohort Month
-- Columns = Month 0, 1, 2, 3, 4+
-- ============================================================

CREATE TABLE cohort_retention_pivot AS
SELECT
cohort_month,
cohort_size,
-- Month 0 (always 100%)
MAX(CASE WHEN month_number = 0 THEN retention_pct END) AS month_0,
-- Month 1
MAX(CASE WHEN month_number = 1 THEN retention_pct END) AS month_1,
-- Month 2
MAX(CASE WHEN month_number = 2 THEN retention_pct END) AS month_2,
-- Month 3
MAX(CASE WHEN month_number = 3 THEN retention_pct END) AS month_3,
-- Month 4+
MAX(CASE WHEN month_number >= 4 THEN retention_pct END) AS month_4_plus

FROM cohort_retention_matrix
GROUP BY cohort_month, cohort_size
ORDER BY cohort_month;

-- Check
SELECT * FROM cohort_retention_pivot;


-- ============================================================
-- PART E: PURCHASE COHORT ANALYSIS
-- Did users purchase again after first purchase?
-- ============================================================
CREATE TABLE purchase_cohort AS
WITH
-- Users who made at least 1 purchase
buyers AS (
SELECT
visitorid,
MIN(event_datetime) AS first_purchase_date,
DATE_TRUNC('month',
MIN(event_datetime)) AS purchase_cohort_month,
COUNT(*) AS total_purchases
FROM master_clean_events
WHERE event_type = 'transaction'
GROUP BY visitorid
)

SELECT
purchase_cohort_month,
COUNT(*) AS cohort_buyers,

-- Repeat buyers (2+ purchases)
SUM(CASE WHEN total_purchases >= 2 THEN 1 ELSE 0 END) AS repeat_buyers,
-- One time buyers
SUM(CASE WHEN total_purchases = 1 THEN 1 ELSE 0 END) AS one_time_buyers,
-- Repeat purchase rate
ROUND(SUM(CASE WHEN total_purchases >= 2 THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0) , 2) AS repeat_purchase_rate,
-- Avg purchases per buyer
ROUND(AVG(total_purchases), 2) AS avg_purchases_per_buyer

FROM buyers
GROUP BY purchase_cohort_month
ORDER BY purchase_cohort_month;

-- Check
SELECT * FROM purchase_cohort;


-- ============================================================
-- PART F: COHORT QUALITY
-- Best and worst retention cohorts
-- ============================================================

CREATE TABLE cohort_quality AS
WITH

-- Average retention at month 1
month1_retention AS (
SELECT
cohort_month,
cohort_size,
retention_pct AS month1_retention
FROM cohort_retention_matrix
WHERE month_number = 1)

SELECT
cohort_month,
cohort_size,
month1_retention,

RANK() OVER (
ORDER BY month1_retention DESC) AS retention_rank,
CASE WHEN RANK() OVER (ORDER BY month1_retention DESC) = 1 THEN 'Best Cohort'
WHEN RANK() OVER (ORDER BY month1_retention ASC) = 1 THEN 'Worst Cohort'
ELSE 'Average'
END AS cohort_quality

FROM month1_retention
ORDER BY month1_retention DESC;

-- Check
SELECT * FROM cohort_quality;


-- ============================================================
-- PART G: COMBINED COHORT DATA FOR EXPORT
-- ============================================================

CREATE TABLE cohort_retention AS

-- Retention Matrix (main export)
SELECT
crp.cohort_month::TEXT AS cohort_month,
crp.cohort_size,
crp.month_0,
crp.month_1,
crp.month_2,
crp.month_3,
crp.month_4_plus,

-- Cohort quality tag
cq.cohort_quality

FROM cohort_retention_pivot crp
LEFT JOIN cohort_quality cq
ON crp.cohort_month = cq.cohort_month
ORDER BY crp.cohort_month;

-- Check
SELECT * FROM cohort_retention;


-- ============================================================
-- EXPORT
-- ============================================================

COPY cohort_retention
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\cohort_retention.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY purchase_cohort
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\purchase_cohort.csv'
WITH (FORMAT CSV, HEADER TRUE);