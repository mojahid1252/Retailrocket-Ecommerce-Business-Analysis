-- ============================================================
-- SQL 01: DATA CLEANING
-- Project: E-Commerce Conversion Intelligence
-- Dataset: Retail Rocket (Kaggle)
-- Tool: PostgreSQL
--
-- ⚠️ IMPORTANT NOTE:
-- Price column exists in item_properties but is encoded.
-- NOT real currency values.
-- No monetary analysis will be performed.
-- Conversion rate = primary success metric.
-- ============================================================

-- PART A: MERGE ITEM PROPERTIES (Part 1 + Part 2)
CREATE TABLE raw_item_properties_combined AS
SELECT * FROM raw_item_properties_1
UNION ALL
SELECT * FROM raw_item_properties_2;

-- Verify
SELECT COUNT(*) as total_rows
FROM raw_item_properties_combined;

SELECT * FROM raw_item_properties_combined;


-- Step B1: Get latest categoryid per item
CREATE TABLE item_category AS
SELECT DISTINCT ON (itemid)itemid,
value::BIGINT as categoryid
FROM raw_item_properties_combined
WHERE property = 'categoryid' AND value ~ '^[0-9]+$'
ORDER BY itemid, timestamp_ms DESC;

-- Step B2: Get latest availability per item
CREATE TABLE item_availability AS
SELECT DISTINCT ON (itemid)itemid,
value::INTEGER as available
FROM raw_item_properties_combined
WHERE property = 'available'AND value IN ('0', '1')
ORDER BY itemid, timestamp_ms DESC;

-- Verify
SELECT COUNT(*) FROM item_category;
SELECT COUNT(*) FROM item_availability;

SELECT * FROM item_category;
SELECT * FROM item_availability;


-- ============================================================
-- PART C: CLEAN EVENTS TABLE
-- ============================================================
-- Events table 
SELECT * FROM raw_events LIMIT 100;
-- Item properties 
SELECT * FROM raw_item_properties_1 LIMIT 10;
SELECT * FROM raw_item_properties_2 LIMIT 10;
-- Category tree 
SELECT * FROM raw_category_tree LIMIT 10;

-- Step C1: Create cleaned events with datetime conversion
-- Remove duplicates
-- Validate event types
-- Add time features

CREATE TABLE clean_events AS
-- Remove exact duplicates first
WITH
deduplicated AS (
SELECT DISTINCT
timestamp_ms,
visitorid,
event,
itemid,
transactionid
FROM raw_events
WHERE event IN ('view', 'addtocart', 'transaction')
),
-- Convert timestamp and add time features
with_datetime AS (
SELECT
visitorid,
event AS event_type,
itemid,
transactionid,
timestamp_ms,
-- Convert Unix milliseconds to datetime
TO_TIMESTAMP(timestamp_ms / 1000.0)AS event_datetime,
-- Extract HOUR
EXTRACT(HOUR FROM TO_TIMESTAMP(timestamp_ms / 1000.0))::INTEGER AS hour_of_day,
-- Extract DAY OF WEEK
-- 0=Sunday, 1=Monday, ..., 6=Saturday
EXTRACT(DOW FROM TO_TIMESTAMP(timestamp_ms / 1000.0))::INTEGER AS day_of_week,
-- Weekend Flag
CASE WHEN EXTRACT(DOW FROM TO_TIMESTAMP(timestamp_ms / 1000.0))IN (0, 6) THEN 1 ELSE 0 END 
AS is_weekend 
FROM deduplicated)
SELECT * FROM with_datetime;

SELECT * FROM clean_events;
-- ============================================================
-- VERIFY PART C
-- ============================================================

-- Total rows
SELECT COUNT(*) as total_events
FROM clean_events;

-- Event type breakdown
SELECT
event_type,
COUNT(*) as count,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)AS percentage
FROM clean_events
GROUP BY event_type
ORDER BY count DESC;

-- Date range check
SELECT 
MIN(event_datetime) as dataset_start,
MAX(event_datetime) as dataset_end
FROM clean_events;

-- ============================================================
-- PART D: CREATE SESSION IDs
-- Rule: 30 minutes inactivity = new session
-- Industry standard session definition
-- ============================================================

CREATE TABLE clean_events_with_sessions AS
WITH
-- Calculate time difference between consecutive events per user
time_gaps AS (
SELECT*,
LAG(event_datetime) OVER (PARTITION BY visitorid ORDER BY event_datetime) AS prev_event_time FROM clean_events),

-- Flag where a new session starts
-- New session = first event OR gap > 30 minutes
session_flags AS (
SELECT*,
CASE WHEN prev_event_time IS NULL THEN 1
WHEN EXTRACT(EPOCH FROM(event_datetime - prev_event_time)) > 1800 THEN 1 
ELSE 0 END AS is_new_session
FROM time_gaps),

-- Create cumulative session counter per user
session_numbers AS (
SELECT*,
SUM(is_new_session) OVER ( PARTITION BY visitorid ORDER BY event_datetime ROWS UNBOUNDED PRECEDING) AS session_num
FROM session_flags)

-- Build final session_id
SELECT
visitorid,
CONCAT(visitorid, '_', session_num) AS session_id,
session_num,
event_type,
itemid,
transactionid,
event_datetime,
hour_of_day,
day_of_week,
is_weekend
FROM session_numbers;


-- ============================================================
-- VERIFY PART D
-- ============================================================

-- Total sessions
SELECT COUNT(DISTINCT session_id) as total_sessions
FROM clean_events_with_sessions;
-- Total visitors
SELECT COUNT(DISTINCT visitorid) as total_visitors
FROM clean_events_with_sessions;
-- Avg sessions per visitor
SELECT ROUND(COUNT(DISTINCT session_id) * 1.0 / COUNT(DISTINCT visitorid), 2) as avg_sessions_per_visitor
FROM clean_events_with_sessions;
-- Session distribution
SELECT
session_num,
COUNT(DISTINCT visitorid) as visitors
FROM clean_events_with_sessions
GROUP BY session_num
ORDER BY session_num
LIMIT 10;

SELECT * FROM clean_events_with_sessions;

-- ============================================================
-- PART E: JOIN ITEM PROPERTIES TO EVENTS
-- Add categoryid and available status to each event
-- ============================================================
CREATE TABLE master_clean_events AS
SELECT
e.visitorid,
e.session_id,
e.session_num,
e.event_type,
e.itemid,
e.transactionid,
e.event_datetime,
e.hour_of_day,
e.day_of_week,
e.is_weekend,
-- From item_category table
COALESCE(ic.categoryid, -1) AS categoryid,
-- -1 means category not found

-- From item_availability table
COALESCE(ia.available, -1)  AS available
-- -1 means availability not found

FROM clean_events_with_sessions e

LEFT JOIN item_category ic
ON e.itemid = ic.itemid

LEFT JOIN item_availability ia
ON e.itemid = ia.itemid;


-- ============================================================
-- VERIFY PART E
-- ============================================================

-- Total rows
SELECT COUNT(*) as total_rows
FROM master_clean_events;

-- Unique counts
SELECT
COUNT(DISTINCT visitorid)  as unique_visitors,
COUNT(DISTINCT session_id) as unique_sessions,
COUNT(DISTINCT itemid)     as unique_items,
COUNT(DISTINCT categoryid) as unique_categories
FROM master_clean_events;

-- Category coverage
SELECT
SUM(CASE WHEN categoryid = -1 THEN 1 ELSE 0 END) as missing_category,
SUM(CASE WHEN categoryid != -1 THEN 1 ELSE 0 END) as has_category,
ROUND(SUM(CASE WHEN categoryid != -1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) As category_coverage_pct
FROM master_clean_events;

-- Availability coverage
SELECT
SUM(CASE WHEN available = 1 THEN 1 ELSE 0 END) as available_items,
SUM(CASE WHEN available = 0 THEN 1 ELSE 0 END) as unavailable_items,
SUM(CASE WHEN available = -1 THEN 1 ELSE 0 END) as unknown_availability
FROM master_clean_events;

-- Sample data check
SELECT *
FROM master_clean_events
LIMIT 10;


-- ============================================================
-- STEP 7: QUALITY CHECKS
-- ============================================================


-- ============================================================
-- Check 1: Event type distribution
-- ============================================================
SELECT
event_type,
COUNT(*) as count,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2)AS percentage
FROM master_clean_events
GROUP BY event_type
ORDER BY count DESC;

-- ============================================================
-- Check 2: NULL check on key columns
-- ============================================================
SELECT
COUNT(*) as total_rows,
COUNT(visitorid) as non_null_visitor,
COUNT(session_id) as non_null_session,
COUNT(event_type) as non_null_event,
COUNT(itemid) as non_null_item,
SUM(CASE WHEN categoryid = -1
THEN 1 ELSE 0 END) as missing_category,
SUM(CASE WHEN available = -1 THEN 1 ELSE 0 END) as missing_availability
FROM master_clean_events;


-- ============================================================
-- Check 3: Date range of dataset
-- ============================================================
SELECT
MIN(event_datetime) as dataset_start,
MAX(event_datetime) as dataset_end,
MAX(event_datetime) - MIN(event_datetime) AS duration
FROM master_clean_events;

-- ============================================================
-- Check 4: Transaction NULL check
-- NULL is VALID for view and addtocart events
-- ============================================================
SELECT
event_type,
COUNT(*) as total,
COUNT(transactionid) as has_transaction_id,
SUM(CASE WHEN transactionid IS NULL THEN 1 ELSE 0 END) as null_transaction_id
FROM master_clean_events
GROUP BY event_type;

-- ============================================================
-- Check 5: Weekend distribution
-- ============================================================
SELECT
CASE WHEN is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
COUNT(*) as event_count,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) as percentage
FROM master_clean_events
GROUP BY is_weekend;

-- ============================================================
-- Check 6: Hour distribution
-- ============================================================
SELECT
hour_of_day,
COUNT(*)as total_events,
SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) as views,
SUM(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) as carts,
SUM(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) as purchases
FROM master_clean_events
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- ============================================================
-- Check 7: Day of week distribution
-- ============================================================
SELECT
CASE day_of_week
WHEN 0 THEN 'Sunday'
WHEN 1 THEN 'Monday'
WHEN 2 THEN 'Tuesday'
WHEN 3 THEN 'Wednesday'
WHEN 4 THEN 'Thursday'
WHEN 5 THEN 'Friday'
WHEN 6 THEN 'Saturday'
END AS day_name,
day_of_week,
COUNT(*) as event_count
FROM master_clean_events
GROUP BY day_of_week
ORDER BY day_of_week;

-- ============================================================
-- Check 8: Session size distribution
-- ============================================================
SELECT
events_per_session,
COUNT(*) as session_count
FROM 
(SELECT session_id,
COUNT(*) as events_per_session
FROM master_clean_events
GROUP BY session_id) session_sizes
GROUP BY events_per_ession
ORDER BY events_per_session
LIMIT 20;

SELECT * FROM master_clean_events;

-- ============================================================
-- STEP 8: EXPORT master_clean_events to CSV
-- ============================================================
COPY master_clean_events
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\DATA\clean_events.csv'
WITH (FORMAT CSV, HEADER TRUE);



