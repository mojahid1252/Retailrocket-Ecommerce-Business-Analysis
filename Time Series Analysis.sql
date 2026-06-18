-- ============================================================
-- SQL 08: TIME SERIES ANALYSIS
-- Project: E-Commerce Conversion Intelligence
-- Dataset: Retail Rocket (Kaggle)
-- Tool: PostgreSQL
--
-- Business Question:
-- When do users engage most?
-- What time patterns affect conversion?
-- ============================================================


-- ============================================================
-- PART A: DAILY EVENT COUNTS
-- ============================================================

CREATE TABLE daily_events AS
SELECT
DATE_TRUNC('day',event_datetime)::DATE AS event_date,
COUNT(*) AS total_events,
SUM(CASE WHEN event_type = 'view'THEN 1 ELSE 0 END) AS daily_views,
SUM(CASE WHEN event_type = 'addtocart'THEN 1 ELSE 0 END) AS daily_carts,
SUM(CASE WHEN event_type = 'transaction'THEN 1 ELSE 0 END) AS daily_purchases,
COUNT(DISTINCT visitorid) AS unique_visitors,
COUNT(DISTINCT session_id) AS unique_sessions,
-- Daily CVR
ROUND(COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN visitorid END) * 100.0 
/ NULLIF(COUNT(DISTINCT visitorid), 0), 4) AS daily_cvr

FROM master_clean_events
GROUP BY DATE_TRUNC('day', event_datetime)::DATE
ORDER BY event_date;

-- Check
SELECT * FROM daily_events;
SELECT COUNT(*) as total_days FROM daily_events;


-- ============================================================
-- PART B: WEEKLY ROLLING 7-DAY TRENDS
-- ============================================================
CREATE TABLE weekly_rolling AS
SELECT
event_date,
daily_views,
daily_carts,
daily_purchases,
unique_visitors,
daily_cvr,
-- 7-day rolling average views
ROUND(AVG(daily_views) OVER (ORDER BY event_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS rolling_7d_views,
-- 7-day rolling average purchases
ROUND(AVG(daily_purchases) OVER (ORDER BY event_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS rolling_7d_purchases,
-- 7-day rolling CVR
ROUND(AVG(daily_cvr) OVER (ORDER BY event_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 4) AS rolling_7d_cvr,
-- 7-day rolling unique visitors
ROUND(AVG(unique_visitors) OVER (ORDER BY event_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS rolling_7d_visitors

FROM daily_events
ORDER BY event_date;

-- Check
SELECT * FROM weekly_rolling;


-- ============================================================
-- PART C: HOURLY PATTERNS
-- 24-hour pattern per event type
-- ============================================================

CREATE TABLE hourly_patterns AS
SELECT
hour_of_day,
COUNT(*) AS total_events,
SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS hourly_views,
SUM(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) AS hourly_carts,
SUM(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) AS hourly_purchases,
COUNT(DISTINCT visitorid) AS unique_visitors,
-- Hourly CVR
ROUND(COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN visitorid END) * 100.0 
/ NULLIF(COUNT(DISTINCT visitorid), 0), 4) AS hourly_cvr,
-- Share of daily events
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total_events

FROM master_clean_events
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- Check
SELECT * FROM hourly_patterns;

-- Peak hours
SELECT
hour_of_day,
hourly_purchases,
hourly_cvr
FROM hourly_patterns
ORDER BY hourly_purchases DESC
LIMIT 5;


-- ============================================================
-- PART D: DAY OF WEEK PATTERNS
-- ============================================================

CREATE TABLE dayofweek_patterns AS
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
is_weekend,
COUNT(*) AS total_events,
SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS day_views,
SUM(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) AS day_carts,
SUM(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) AS day_purchases,
COUNT(DISTINCT visitorid) AS unique_visitors,
-- Day CVR
ROUND(COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN visitorid END) * 100.0 /
NULLIF(COUNT(DISTINCT visitorid), 0), 4) AS day_cvr,
-- Avg per day of week
ROUND(COUNT(*) * 1.0 /COUNT(DISTINCT DATE_TRUNC('day', event_datetime)), 2) AS avg_events_per_day

FROM master_clean_events
GROUP BY day_of_week, is_weekend
ORDER BY day_of_week;

-- Check
SELECT * FROM dayofweek_patterns;


-- ============================================================
-- PART E: WEEKEND VS WEEKDAY COMPARISON
-- ============================================================

CREATE TABLE weekend_weekday_comparison AS
SELECT
CASE WHEN is_weekend = 1
THEN 'Weekend'
ELSE 'Weekday'
END AS day_type,
COUNT(*) AS total_events,
SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS total_views,
SUM(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) AS total_carts,
SUM(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) AS total_purchases,
COUNT(DISTINCT visitorid) AS unique_visitors,
COUNT(DISTINCT session_id) AS unique_sessions,
-- CVR
ROUND(COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN visitorid END) * 100.0 /NULLIF(COUNT(DISTINCT visitorid), 0), 4) AS cvr,
-- Avg events per session
ROUND(COUNT(*) * 1.0 / NULLIF(COUNT(DISTINCT session_id), 0), 2) AS avg_events_per_session

FROM master_clean_events
GROUP BY is_weekend
ORDER BY is_weekend;

-- Check
SELECT * FROM weekend_weekday_comparison;


-- ============================================================
-- PART F: MONTH OVER MONTH CHANGE
-- ============================================================

CREATE TABLE monthly_trends AS
WITH
monthly_stats AS (
SELECT
DATE_TRUNC('month', event_datetime)::DATE AS event_month,
COUNT(*) AS total_events,
SUM(CASE WHEN event_type = 'view' THEN 1 ELSE 0 END) AS monthly_views,
SUM(CASE WHEN event_type = 'addtocart' THEN 1 ELSE 0 END) AS monthly_carts,
SUM(CASE WHEN event_type = 'transaction' THEN 1 ELSE 0 END) AS monthly_purchases,
COUNT(DISTINCT visitorid) AS unique_visitors,
ROUND(COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN visitorid END) * 100.0 /
NULLIF(COUNT(DISTINCT visitorid), 0), 4) AS monthly_cvr
FROM master_clean_events
GROUP BY DATE_TRUNC('month', event_datetime)
)
SELECT
event_month,
total_events,
monthly_views,
monthly_carts,
monthly_purchases,
unique_visitors,
monthly_cvr,
-- Month over month change in visitors
LAG(unique_visitors) OVER (ORDER BY event_month) AS prev_month_visitors,
ROUND((unique_visitors - LAG(unique_visitors) OVER (ORDER BY event_month)) * 100.0 /
NULLIF(LAG(unique_visitors) OVER (ORDER BY event_month), 0), 2) AS visitor_mom_change_pct,
-- Month over month change in purchases
LAG(monthly_purchases) OVER (ORDER BY event_month) AS prev_month_purchases,
ROUND((monthly_purchases - LAG(monthly_purchases) OVER (ORDER BY event_month)) * 100.0 /
NULLIF(LAG(monthly_purchases) OVER (ORDER BY event_month), 0), 2) AS purchase_mom_change_pct,
-- Month over month CVR change
LAG(monthly_cvr) OVER (ORDER BY event_month) AS prev_month_cvr,
ROUND(monthly_cvr - LAG(monthly_cvr) OVER (ORDER BY event_month),4) AS cvr_mom_change

FROM monthly_stats
ORDER BY event_month;

-- Check
SELECT * FROM monthly_trends;


-- ============================================================
-- PART G: ANOMALY FLAGS
-- Days with unusual traffic spikes
-- ============================================================

CREATE TABLE anomaly_flags AS
WITH
daily_stats AS (
SELECT
event_date,
daily_views,
daily_purchases,
unique_visitors,
daily_cvr,
-- Mean and StdDev
AVG(daily_views) OVER () AS mean_views,
STDDEV(daily_views) OVER () AS std_views,

AVG(unique_visitors) OVER () AS mean_visitors,
STDDEV(unique_visitors) OVER () AS std_visitors,

AVG(daily_cvr) OVER () AS mean_cvr,
STDDEV(daily_cvr) OVER () AS std_cvr

FROM daily_events
)
SELECT
event_date,
daily_views,
daily_purchases,
unique_visitors,
daily_cvr,

ROUND(mean_views, 2) AS mean_views,
ROUND(std_views, 2) AS std_views,

-- Z-score for views
ROUND((daily_views - mean_views) /NULLIF(std_views, 0), 2) AS views_zscore,
-- Z-score for visitors
ROUND((unique_visitors - mean_visitors) /NULLIF(std_visitors, 0), 2) AS visitors_zscore,
-- Z-score for CVR
ROUND((daily_cvr - mean_cvr) /NULLIF(std_cvr, 0), 2) AS cvr_zscore,
-- Anomaly Flag
CASE
WHEN ABS((daily_views - mean_views) / NULLIF(std_views, 0)) > 2 THEN 'Traffic Spike'
WHEN ABS((daily_cvr - mean_cvr) /NULLIF(std_cvr, 0)) > 2 THEN 'CVR Anomaly'
ELSE 'Normal' 
END AS anomaly_flag

FROM daily_stats
ORDER BY event_date;

-- Check anomaly days
SELECT *
FROM anomaly_flags
WHERE anomaly_flag != 'Normal'
ORDER BY views_zscore DESC;


-- ============================================================
-- PART H: PEAK HOUR PER EVENT TYPE
-- ============================================================

CREATE TABLE peak_hours AS
WITH hour_ranks AS (
SELECT
event_type,
hour_of_day,
COUNT(*) AS event_count,
RANK() OVER (PARTITION BY event_type ORDER BY COUNT(*) DESC) AS hour_rank
FROM master_clean_events
GROUP BY event_type, hour_of_day)
SELECT
event_type,
hour_of_day AS peak_hour,
event_count
FROM hour_ranks
WHERE hour_rank = 1
ORDER BY event_type;

-- Check
SELECT * FROM peak_hours;


-- ============================================================
-- PART I: COMBINED TIME SERIES FOR EXPORT
-- ============================================================
CREATE TABLE time_series_data AS

-- Daily data (main)
SELECT
    'daily' AS time_granularity,
    de.event_date::TEXT AS time_period,
    de.total_events,
    de.daily_views AS views,
    de.daily_carts AS carts,
    de.daily_purchases AS purchases,
    de.unique_visitors,
    de.unique_sessions,
    de.daily_cvr AS cvr,
    wr.rolling_7d_views,
    wr.rolling_7d_purchases,
    wr.rolling_7d_cvr,
    af.anomaly_flag

FROM daily_events de
LEFT JOIN weekly_rolling wr
    ON de.event_date = wr.event_date
LEFT JOIN anomaly_flags af
    ON de.event_date = af.event_date

UNION ALL

-- Hourly data
SELECT
    'hourly' AS time_granularity,
    hour_of_day::TEXT AS time_period,
    total_events,
    hourly_views AS views,
    hourly_carts AS carts,
    hourly_purchases AS purchases,
    unique_visitors,
    NULL AS unique_sessions,
    hourly_cvr AS cvr,
    NULL AS rolling_7d_views,
    NULL AS rolling_7d_purchases,
    NULL AS rolling_7d_cvr,
    NULL AS anomaly_flag

FROM hourly_patterns

UNION ALL

-- Day of week data
SELECT
    'day_of_week' AS time_granularity,
    day_name AS time_period,
    total_events,
    day_views AS views,
    day_carts AS carts,
    day_purchases AS purchases,
    unique_visitors,
    NULL AS unique_sessions,
    day_cvr AS cvr,
    NULL AS rolling_7d_views,
    NULL AS rolling_7d_purchases,
    NULL AS rolling_7d_cvr,
    NULL AS anomaly_flag

FROM dayofweek_patterns;


-- Check table
SELECT * FROM time_series_data LIMIT 20;

-- Count by granularity
SELECT
time_granularity,
COUNT(*) AS record_count
FROM time_series_data
GROUP BY time_granularity;





COPY time_series_data
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\time_series_data.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY monthly_trends
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\monthly_trends.csv'
WITH (FORMAT CSV, HEADER TRUE);

COPY anomaly_flags
TO 'E:\Retailrocket-Ecommerce-Business-Analysis\SQL\PROJECT FILE\anomaly_flags.csv'
WITH (FORMAT CSV, HEADER TRUE);
