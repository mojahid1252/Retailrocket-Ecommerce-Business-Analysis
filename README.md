<div align="center">

# 🚀 E-Commerce Conversion Intelligence
###  End-to-end analytics project on 2M+ real e-commerce data

**Where users drop off, why they abandon, and what makes them buy - powered by SQL, Python & Power BI**

[![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?style=for-the-badge&logo=powerbi&logoColor=black)]()
[![SQL](https://img.shields.io/badge/SQL-Analysis-4479A1?style=for-the-badge&logo=mysql&logoColor=white)]()
[![Python](https://img.shields.io/badge/Python-Statistics-3776AB?style=for-the-badge&logo=python&logoColor=white)]()
[![Status](https://img.shields.io/badge/Status-Completed-brightgreen?style=for-the-badge)]()
[![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)]()

---

<!-- 🖼️ HERO IMAGE — Replace with your most impressive dashboard screenshot -->
<img src=https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/cf0b53f61cece9f0f77b20e07a5c7dd6bceb48c4/Executive%20Overview.png/>

*Executive Overview Dashboard - Real-time conversion intelligence at a glance*

</div>

---

## 📌 Project Overview

This project delivers an **end-to-end behavioral analytics solution** for the Retail Rocket e-commerce platform, where **1.4 million visitors** generate over **2.75 million events** - yet **97%+ leave without purchasing**. Through systematic funnel analysis, behavioral segmentation, cart abandonment profiling, and rigorous statistical testing, this project uncovers the precise points of conversion failure and identifies high-impact, data-driven opportunities to improve purchase rates across the entire customer journey.

### 🎯 Business Problem

Traffic is growing but conversion is **NOT** improving proportionally. **97%+ visitors leave without purchasing** and the cart abandonment rate hovers around **76%** - but the business has no visibility into **WHERE** users drop off, **WHY** they abandon carts, and **WHO** is most likely to convert. Without this intelligence, every marketing dollar and product recommendation is a shot in the dark.

### 💡 Solution

A **three-phase analytical pipeline** - SQL for data cleaning and core analysis, Python for advanced statistical testing, and Power BI for interactive visualization - that transforms raw behavioral event data into actionable conversion intelligence. Every insight is grounded in statistical significance (p-values), every segment is behaviorally defined (not assumed), and every recommendation is tied to a measurable conversion metric.

### 📊 Key Results

| Metric | Value | Impact |
|--------|-------|--------|
| Overall Conversion Rate | **2.14%** | 97%+ visitors never purchase |
| Cart Abandonment Rate | **~76.8%** | 3 in 4 cart-adders abandon |
| Multi-session User Lift | **3x more likely** to buy | Retargeting opportunity |
| Evening vs Morning CVR | **Statistically higher** (p < 0.05) | Campaign timing optimization |
| Hidden Gem Products | **High CVR, zero traffic** | Untapped conversion potential |
| Out-of-Stock Waste | **Significant traffic on unavailable items** | Wasted sessions draining CVR |

## 📁 Repository Structure

```
retail-rocket-analytics/
│
├── 📁 data/
│   ├── 📁 raw/
│   │   ├── events.csv                    # 2.75M behavioral events
│   │   ├── item_properties_1.csv         # Item attributes part 1
│   │   ├── item_properties_2.csv         # Item attributes part 2
│   │   └── category_tree.csv             # Category hierarchy
│   │
│   └── 📁 processed/
│       ├── clean_events.csv              # Master cleaned events table
│       ├── funnel_summary.csv            # Funnel stage metrics
│       ├── conversion_metrics.csv        # Overall + segment CVR
│       ├── cart_abandonment.csv          # Cart abandonment profiling
│       ├── behavior_segments.csv         # RFE segments + behavioral labels
│       ├── product_performance.csv       # Product metrics + quadrant classification
│       ├── cohort_retention.csv          # Retention matrix data
│       ├── category_analysis.csv         # Category-level performance
│       ├── time_series_data.csv          # Temporal patterns + anomaly flags
│       ├── hypothesis_test_data.csv      # Statistical test inputs
│       ├── simulated_ab_groups.csv       # A/B test group statistics
│       └── features_master.csv           # 35+ engineered features
│
├── 📁 sql/
│   ├── 01_data_cleaning.sql              # Load, clean, session creation
│   ├── 02_funnel_analysis.sql            # Conversion funnel + drop-off rates
│   ├── 03_conversion_metrics.sql         # Overall + segment-level CVR
│   ├── 04_cart_abandonment.sql           # Cart abandonment deep dive
│   ├── 05_behavior_segmentation.sql      # RFE scoring + behavioral labels
│   ├── 06_product_analysis.sql           # Product performance + quadrants
│   ├── 07_cohort_analysis.sql            # Retention heatmap data
│   ├── 08_time_series_analysis.sql       # Daily/hourly/weekly patterns
│   ├── 09_category_analysis.sql          # Category tree + performance
│   └── 10_ab_test_data_prep.sql          # Simulated A/B group creation
│
├── 📁 python/
│   ├── 00_feature_engineering.ipynb      # 35+ features (session/user/item/time/behavioral)
│   ├── 01_probability_analysis.ipynb     # Basic, conditional, Bayes, joint probability
│   ├── 02_distribution_analysis.ipynb    # Distribution fitting + outlier detection
│   ├── 03_hypothesis_testing.ipynb       # 5 tests with H₀/H₁/conclusion
│   └── 04_simulated_ab_testing.ipynb     # 5 simulated A/B tests + power analysis
│
├── 📁 powerbi/
│   └── retail_rocket_dashboard.pbix      # 8-page interactive dashboard
│
├── 📁 exports/
│   ├── 📁 charts/
│   │   ├── funnel_chart.png
│   │   ├── cart_abandonment_chart.png
│   │   ├── behavior_segment_map.png
│   │   ├── cohort_heatmap.png
│   │   ├── distribution_plots.png
│   │   ├── hypothesis_results.png
│   │   ├── ab_test_results.png
│   │   └── insights_summary.png
│   │
│   └── 📁 reports/
│       └── final_business_report.pdf
│
└── 📄 README.md
```

## 📦 Dataset

**Source:** [Kaggle — Retail Rocket E-Commerce Dataset](https://www.kaggle.com/datasets/retailrocket/ecommerce-dataset)

### Overview

| Detail | Value |
|--------|-------|
| Platform | Retail Rocket (Real E-Commerce) |
| Total Events | 2,756,101 |
| Unique Visitors | 1,407,580 |
| Event Types | `view` · `addtocart` · `transaction` |
| Time Period | ~4.5 months |
| Category Hierarchy | ~1,600 nodes |

### Files

| File | Description |
|------|-------------|
| `events.csv` | User behavioral events (view, addtocart, transaction) |
| `item_properties_1.csv` | Item attributes - category, availability, encoded price (Part 1) |
| `item_properties_2.csv` | Item attributes - continued (Part 2) |
| `category_tree.csv` | Parent-child category hierarchy |

### Schema (events.csv)

| Column | Type | Description |
|--------|------|-------------|
| `timestamp` | Unix epoch | Event time → converted to datetime in SQL |
| `visitorid` | Integer | Unique user identifier |
| `event` | String | `view` · `addtocart` · `transaction` |
| `itemid` | Integer | Product identifier |
| `transactionid` | Integer | Purchase ID (`NULL` for view/addtocart - valid, not missing) |

### Data Flow

```
Raw CSVs → SQL Cleaning (01_data_cleaning.sql) → clean_events.csv → All Analysis
```

### ⚠️ Important Notes

- **No real monetary values** - price column is encoded, not actual currency
- **Conversion rate = primary success metric** throughout this project
- **No user demographics** - age, location, device not available
- **No product names** - only item IDs and category IDs
- **A/B test groups don't exist** - simulated retrospectively for analytical demonstration
- **NULL transactionid is valid** - view & addtocart events don't generate transaction IDs

### Why This Dataset?

> This dataset is ideal for **conversion funnel analysis** because it captures the complete behavioral journey from product view → cart → purchase at real e-commerce scale. The absence of monetary data forces a focus on **behavioral signals and conversion metrics** - which is where most e-commerce analytics teams start before connecting revenue data.

---

## 🗄️ Data Architecture

```
Raw CSV Data → SQL Cleaning & Feature Engineering → Processed CSVs → Power BI Data Model → 8-Page Dashboard
```

### Data Sources

| Source | Description | Records |
|--------|-------------|---------|
| `events.csv` | User behavioral events (view, addtocart, transaction) | 2,756,101 |
| `item_properties_1.csv` | Item attributes (category, availability, price encoded) | Part 1 |
| `item_properties_2.csv` | Item attributes (continued) | Part 2 |
| `category_tree.csv` | Category parent-child hierarchy | ~1,600 |

### Data Model

**Flat schema with derived tables** - Each SQL analysis outputs a clean CSV that maps to a dedicated Power BI table. The `clean_events` table serves as the central fact table, with dimension tables for products, categories, and user segments created through SQL transformations.

### Key Tables

| Table Name | Rows | Key Columns | Purpose |
|------------|------|-------------|---------|
| `clean_events` | 2.75M | visitorid, session_id, event_type, itemid, categoryid, hour_of_day, day_of_week, transactionid | Master fact table after cleaning |
| `funnel_summary` | Varies | stage, user_count, conversion_rate, drop_off_rate | Funnel stage metrics |
| `conversion_metrics` | Varies | segment, cvr, metric_type | Overall + segment-level CVR |
| `cart_abandonment` | Varies | user_segment, abandonment_rate, time_to_abandon, recovery_rate | Cart abandonment profiling |
| `behavior_segments` | 1.4M | visitorid, recency_score, frequency_score, engagement_score, rfe_total, segment, behavioral_label | RFE segmentation + labels |
| `product_performance` | Varies | itemid, views, carts, purchases, view_to_cart_rate, cart_to_purchase_rate, item_cvr, item_quadrant | Product-level metrics + classification |
| `cohort_retention` | Varies | cohort_month, month_offset, active_users, retention_pct | Cohort retention matrix |
| `category_analysis` | Varies | categoryid, total_views, total_purchases, cvr, cart_abandonment_rate | Category-level performance |
| `time_series_data` | Varies | date, event_type, count, rolling_7day, is_anomaly | Temporal patterns + anomaly flags |
| `simulated_ab_groups` | Varies | test_name, group_label, total_users, total_conversions, conversion_rate | A/B test group statistics |
| `features_master` | 1.4M | 35+ engineered features (session, user, item, time, behavioral) | Master feature set for all notebooks |


---

## 🖥️ Dashboard Preview

### Page 1: Executive Overview
<!-- 🖼️ Replace with actual screenshot -->
<img src=https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/cf0b53f61cece9f0f77b20e07a5c7dd6bceb48c4/Executive%20Overview.png/>
> One-page snapshot - Total Users (1.4M), Total Events (2.75M), CVR (2.14%), Cart Abandon Rate (76.8%), Conversion Funnel, Daily Trends, Event Breakdown, Top Categories

### Page 2: Funnel & Drop-off Analysis
<!-- 🖼️ Replace with actual screenshot -->
<img src=https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/ed0f5afe12c24157a9d60a4071ecf1a60cc57bf6/Funnel%20%26%20Drop-off%20Analysis.png/>
> Deep dive into WHERE users drop off - waterfall chart, CVR by hour/day, weekday vs weekend comparison, funnel by top categories

### Page 3: Cart Abandonment Analysis ⭐
<!-- 🖼️ Replace with actual screenshot -->
<img src=https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/ed0f5afe12c24157a9d60a4071ecf1a60cc57bf6/Cart%20Abandonment%20Analysis.png/>
> Answering Q6 directly - abandonment by user segment, time, product, out-of-stock impact, and time-to-abandon distribution

### Page 4: Behavior Segmentation
<!-- 🖼️ Replace with actual screenshot -->
<img src=https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/ed0f5afe12c24157a9d60a4071ecf1a60cc57bf6/Behavior%20Segmentation.png/>
> RFE-based user segments (Power Users → Inactive), behavioral labels (Repeat Buyer, Cart Abandoner, Window Shopper, Bounce User), segment vs CVR mapping

### Page 5: Product Performance Matrix
<!-- 🖼️ Replace with actual screenshot -->
<img src=https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/ed0f5afe12c24157a9d60a4071ecf1a60cc57bf6/Product%20Performance.png/>
> 4-quadrant scatter plot (Stars / Traffic Wasters / Hidden Gems / Dead Products), Pareto analysis, out-of-stock impact, category-level breakdown

### Page 6: Cohort Retention
<!-- 🖼️ Replace with actual screenshot -->
<img src=https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/ed0f5afe12c24157a9d60a4071ecf1a60cc57bf6/Cohort%20Retention%20Analysis.png/>
> Retention heatmap, cohort size trends, average retention curve, best & worst cohort identification

### Page 7: Statistical Results
<!-- 🖼️ Replace with actual screenshot -->
<img src=https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/ed0f5afe12c24157a9d60a4071ecf1a60cc57bf6/Statistical%20Results.png/>
> Hypothesis test summary (5 tests with p-values), simulated A/B test results (5 experiments), confidence interval charts, winner badges

### Page 8: Time & Behavioral Patterns
<!-- 🖼️ Replace with actual screenshot -->
<img src=https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/ed0f5afe12c24157a9d60a4071ecf1a60cc57bf6/Time%20%26%20Behavioral%20Patterns.png/>
> Purchase heatmap (Hour × Day), daily event trends, weekend vs weekday comparison, peak hour KPIs, session depth vs CVR analysis

<!-- 🔗 [View Live Dashboard](#) — *Coming soon* -->

---

## ⭐ North Star Metric

**Purchase Conversion Rate per Session**

```
Session CVR = Total Purchasing Sessions / Total Sessions
```

| Why This Metric? | Reasoning |
|-------------------|-----------|
| **Session-level** (not user-level) | More granular & actionable - user-level CVR hides repeat visits |
| **Reflects EACH visit opportunity** | Every session is a fresh conversion chance |
| **Directly improvable** | Better recommendations, cart recovery, time-targeted promotions |
| **Industry standard** | Session-based tracking is the e-commerce norm |

**Supporting Metrics:** View-to-Cart Rate · Cart-to-Purchase Rate · Cart Abandonment Rate · Avg Events per Session

**Anti-Metrics (NOT used):** Revenue · AOV · GMV - *not available in this dataset*

---

## 🛠️ Tech Stack

| Tool | Purpose | Details |
|------|---------|---------|
| **SQL** | Data Cleaning + Core Analysis | 10 query files covering funnel, segmentation, cohort, cart abandonment, category analysis |
| **Python** | Advanced Statistics | 4 Jupyter notebooks - probability, distributions, hypothesis testing, simulated A/B testing |
| **Power BI** | Interactive Dashboard | 8-page dashboard with KPI cards, funnel, heatmap, scatter matrix, cohort retention |
| **DAX** | Calculated Measures | Session CVR, segment metrics, conditional formatting logic |
| **Pandas / SciPy / Statsmodels** | Statistical Computing | t-tests, chi-square, z-tests, Mann-Whitney U, ANOVA, power analysis |

---


---

## 📊 Key Analyses Performed

### Analysis 1: Conversion Funnel Deep Dive
**Business Question:** Where exactly in the funnel are users dropping off?
**Method:** SQL-based funnel construction tracking Visitors → Viewers → Cart Adders → Buyers with stage-by-stage drop-off rates, broken down by category, hour, day, and weekday/weekend.
**Finding:** The View → Cart transition is the **biggest bottleneck** — the vast majority of users view items but never add to cart. Among those who do add to cart, ~76% abandon before purchasing.
**Business Impact:** Prioritize "Add to Cart" button optimization and social proof elements (e.g., "X people viewing this now") to push users past the first major drop-off point.

---

### Analysis 2: Cart Abandonment Profiling ⭐
**Business Question:** What is the cart abandonment rate and which users are most likely to abandon?
**Method:** SQL analysis of all users who added to cart but never completed purchase, segmented by behavior (single vs multi-session, new vs returning), time (hour, day, weekend), product (most abandoned items/categories, out-of-stock items), and time-to-abandon distribution.
**Finding:** ~76.8% cart abandonment rate. Single-session users and those who viewed fewer items before carting are most likely to abandon. Some unavailable items (available=0) are still being added to carts - a direct waste of purchase intent.
**Business Impact:** Trigger cart recovery notifications within 1 hour of abandonment. Remove out-of-stock items from recommendations immediately. Add "Notify me when back in stock" for unavailable items currently receiving traffic.

---

### Analysis 3: Behavior-Based User Segmentation (RFE)
**Business Question:** Which behavioral segments have the highest conversion probability?
**Method:** Custom RFE scoring (Recency, Frequency, Engagement) using NTILE(5) for each metric, combined into a 3-15 score. Five segments created: Power Users (13-15), Loyal Browsers (10-12), Occasional Users (7-9), Fading Users (4-6), Inactive (1-3). Additional behavioral labels: Repeat Buyer, One-time Buyer, Cart Abandoner, Window Shopper, Bounce User.
**Finding:** Power Users are a tiny percentage of total users but drive the majority of conversion events. These users show detectable behavioral signals within their first 2-3 sessions. Cart Abandoners and Window Shoppers represent the largest recovery opportunity.
**Business Impact:** Build early identification model for Power User signals within first 3 sessions. Create VIP experience for this segment. Retarget Cart Abandoners with personalized recovery messaging within 24 hours.

---

### Analysis 4: Product Performance Matrix
**Business Question:** Which products get traffic but fail to convert?
**Method:** 4-quadrant classification (Stars, Traffic Wasters, Hidden Gems, Dead Products) based on Views × CVR. Pareto analysis to check 80/20 distribution. Out-of-stock waste analysis.
**Finding:** Hidden Gems exist - products with high CVR but critically low visibility. These convert at 2x the average rate when seen but receive almost zero traffic. Simultaneously, Traffic Wasters consume significant impressions but convert poorly. Out-of-stock items continue receiving views through recommendation slots.
**Business Impact:** Feature Hidden Gems in "You Might Also Like" carousels. Audit Traffic Wasters for content/UX issues. Remove unavailable items from all recommendation slots to redirect wasted traffic.

---

### Analysis 5: Time-Based Conversion Patterns
**Business Question:** Does time of day / day of week significantly affect conversion?
**Method:** SQL time series analysis — hourly/daily/weekly trends, peak hour identification, weekday vs weekend CVR comparison, anomaly flagging for unusual traffic spikes. Validated with statistical tests (Chi-Square for time-behavior dependence, Two-Proportion Z-Test for weekday vs weekend).
**Finding:** Evening users (6PM-12AM) convert significantly higher than morning users (p < 0.05). Weekend vs weekday CVR differs statistically. Peak purchase hours are concentrated in the evening window.
**Business Impact:** Schedule all promotional campaigns for the 6PM-10PM window. Increase paid ad spend during peak conversion hours. Send cart abandonment recovery emails at 7PM for maximum open rate.

---

### Analysis 6: Cohort Retention Analysis
**Business Question:** How well do users retained over time? Which cohorts are healthiest?
**Method:** Monthly cohort analysis based on first activity month, tracking retention from Month 0 through Month 4+. Separate purchase cohort tracking repeat purchase rate.
**Finding:** Most cohorts show steep drop-off after Month 0, but certain cohorts retain significantly better. The best-pering cohort provides a benchmark for what "good" retention looks like in this platform.
**Business Impact:** Study the characteristics of the best-retaining cohort to replicate successful acquisition conditions. Implement engagement campaigns at Month 1 to flatten the retention curve.

---

### Analysis 7: Statistical Hypothesis Testing
**Business Question:** Are observed differences statistically significant or just noise?
**Method:** Five rigorous hypothesis tests — Independent t-test (buyers vs non-buyers view count), Chi-Square (event type × time of day), Two-Proportion Z-Test (weekday vs weekend CVR), Mann-Whitney U (session depth vs conversion), One-Way ANOVA (category engagement differences).
**Finding:** All five tests rejected the null hypothesis at p < 0.05. Buyers view significantly more items, purchase behavior depends on time of day, weekday/weekend CVR differs, deeper sessions convert more, and category engagement is not equal.
**Business Impact:** Every key business recommendation in this project is backed by statistical evidence - not intuition. Time-targeted campaigns, session depth strategies, and category-level audits are all validated.

---

### Analysis 8: Simulated A/B Testing
**Business Question:** How would different user segments perform in controlled experiments?
**Method:** Five simulated A/B tests using behavioral/time-based user splits: Morning vs Evening, Single vs Multi-Session, Weekday vs Weekend, Light vs Heavy Viewers, Cart Abandoner Return Pattern. Each test includes pre-test planning (baseline CVR, MDE, sample size calculation), two-proportion z-test, and business recommendation.
**Finding:** All five simulated tests show statistically significant differences. Multi-session users convert 3x more. Evening shoppers outperform morning. Cart abandoners who return have significantly higher final conversion. Heavy viewers show dramatically higher purchase rates.
**Business Impact:** Provides a rigorous framework for real experiment design. Quantifies the potential lift from each intervention, enabling prioritized resource allocation across campaigns.

---

## 🔍 SQL Highlights

### Query 1: Session Creation (30-Min Inactivity Rule)
```sql
-- Purpose: Create session_id using industry-standard 30-min inactivity gap
-- This is the foundation for ALL session-level analysis

WITH ranked_events AS (
    SELECT 
        visitorid,
        event_datetime,
        LAG(event_datetime) OVER (PARTITION BY visitorid ORDER BY event_datetime) AS prev_event_time
    FROM clean_events
),
session_flags AS (
    SELECT 
        visitorid,
        event_datetime,
        prev_event_time,
        CASE 
            WHEN prev_event_time IS NULL THEN 1  -- First event ever
            WHEN EXTRACT(EPOCH FROM (event_datetime - prev_event_time)) / 60 > 30 THEN 1  -- 30+ min gap
            ELSE 0  -- Same session
        END AS is_new_session
    FROM ranked_events
)
SELECT 
    visitorid,
    event_datetime,
    SUM(is_new_session) OVER (PARTITION BY visitorid ORDER BY event_datetime) AS session_id
FROM session_flags;
```
> **Why this matters:** Session definition is the foundation of every conversion metric. Using the 30-minute industry standard ensures our CVR calculations are comparable to industry benchmarks and that each session represents a distinct visit opportunity.

---

### Query 2: Cart Abandonment Rate by User Segment
```sql
-- Purpose: Identify which user segments are most likely to abandon carts
-- Directly answers Business Question Q6

WITH cart_users AS (
    SELECT 
        visitorid,
        COUNT(DISTINCT CASE WHEN event_type = 'addtocart' THEN itemid END) AS cart_items,
        COUNT(DISTINCT CASE WHEN event_type = 'transaction' THEN itemid END) AS purchased_items,
        COUNT(DISTINCT session_id) AS total_sessions
    FROM clean_events
    GROUP BY visitorid
    HAVING COUNT(CASE WHEN event_type = 'addtocart' THEN 1 END) > 0  -- Only users who carted
)
SELECT 
    CASE 
        WHEN total_sessions = 1 THEN 'Single Session'
        ELSE 'Multi Session'
    END AS user_type,
    COUNT(*) AS total_cart_users,
    SUM(CASE WHEN purchased_items = 0 THEN 1 ELSE 0 END) AS abandoners,
    ROUND(
        SUM(CASE WHEN purchased_items = 0 THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100, 
        2
    ) AS abandonment_rate
FROM cart_users
GROUP BY user_type;
```
> **Why this matters:** Single-session users show dramatically higher abandonment rates, revealing that session depth is both a predictor and a lever for cart recovery. This insight drives the retargeting recommendation.

---

### Query 3: Product Quadrant Classification
```sql
-- Purpose: Classify every product into Stars, Traffic Wasters, Hidden Gems, Dead
-- Enables prioritized product strategy decisions

WITH item_metrics AS (
    SELECT 
        itemid,
        COUNT(CASE WHEN event_type = 'view' THEN 1 END) AS views,
        COUNT(CASE WHEN event_type = 'addtocart' THEN 1 END) AS carts,
        COUNT(CASE WHEN event_type = 'transaction' THEN 1 END) AS purchases,
        COUNT(DISTINCT CASE WHEN event_type = 'view' THEN visitorid END) AS unique_viewers
    FROM clean_events
    GROUP BY itemid
    HAVING COUNT(CASE WHEN event_type = 'view' THEN 1 END) > 0
),
quartile_bounds AS (
    SELECT 
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY views) AS view_median,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY 
            CASE WHEN views > 0 THEN purchases::float / unique_viewers ELSE 0 END
        ) AS cvr_median
    FROM item_metrics
)
SELECT 
    i.itemid,
    i.views,
    i.purchases,
    ROUND(i.purchases::float / NULL(i.unique_viewers, 1) * 100, 2) AS cvr_pct,
    CASE 
        WHEN i.views >= q.view_median AND i.purchases::float / NULL(i.unique_viewers, 1) >= q.cvr_median THEN 'Star'
        WHEN i.views >= q.view_median AND i.purchases::float / NULL(i.unique_viewers, 1) < q.cvr_median THEN 'Traffic Waster'
        WHEN i.views < q.view_median AND i.purchases::float / NULL(i.unique_viewers, 1) >= q.cvr_median THEN 'Hidden Gem'
        ELSE 'Dead Product'
    END AS product_quadrant
FROM item_metrics i
CROSS JOIN quartile_bounds q;
```
> **Why this matters:** The Hidden Gems quadrant is the most actionable discovery — these products convert well but are invisible to the algorithm. Promoting them is a low-risk, high-reward strategy.

---
---

## 📜 SQL Files — Complete Breakdown

> All SQL files are located in the `sql/` directory. Run them **in order** (01 → 10) for correct dependency flow.

| # | File | Purpose | Key Output |
|---|------|---------|------------|
| 01 | [`sql/clean_events_postgres.sql`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/52c559648eb3bfa198ef5bc16d0ccd6492c7be31/Data%20Cleaning%20%26%20Create%20Master%20Table.sql)| Load raw CSVs, convert timestamps, remove duplicates, create session_id (30-min rule), merge item properties, build master clean_events table | `clean_events.csv` |
| 02 |  [`sql/funnel_summary_postgre.sql`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/f4d526057b9772aa81d04719fdbaf2186b2926a8/Funnel%20analysis.sql ) | Overall funnel (Visitors → Viewers → Cart → Purchase), conversion rates, drop-off rates, funnel by category/hour/day, session-level funnel      | [`funnel_summary.csv`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/abea3d7996b8a451f330dda845d546a864e50e73/funnel_summary.csv) |
| 03 |  [`sql/conversion_metrics_postgres.sql`]( https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/f4d526057b9772aa81d04719fdbaf2186b2926a8/Conversion%20Metrics.sql) | Overall CVR, view-to-cart rate, cart-to-purchase rate, segment-level CVR (hour, day, category, weekday/weekend, single vs multi-session), purchase probability | [`conversion_metrics.csv`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/abea3d7996b8a451f330dda845d546a864e50e73/conversion_metrics.csv) |
| 04 |  [`sql/cart_abandonment_postgres.sql`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/f4d526057b9772aa81d04719fdbaf2186b2926a8/Cart%20Abandonment%20Analysis.sql ) | Overall abandonment rate, abandonment by user behavior (single/multi, new/returning), by time, by product, out-of-stock in cart, time-to-abandon, abandoner profile | [`cart_abandonment.csv`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/abea3d7996b8a451f330dda845d546a864e50e73/cart_abandonment%20.csv) |
| 05 |  [`sql/behavior_segments_postgres.sql`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/f4d526057b9772aa81d04719fdbaf2186b2926a8/Behavior%20Segmentation.png ) | RFE scoring (Recency, Frequency, Engagement using NTILE(5)), 5 segments (Power Users → Inactive), behavioral labels (Repeat Buyer, Cart Abandoner, Window Shopper, Bounce User) | [`behavior_segments.csv`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/243fc5cee15ec33365510c188e426fe9fac2de3a/behavior_segments.csv) |
| 06 |  [`sql/product_performance_analysis_postgres.sql`]( https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/f4d526057b9772aa81d04719fdbaf2186b2926a8/Product%20Performance%20Analysis.sql) | Per-item metrics, 4-quadrant classification (Stars / Traffic Wasters / Hidden Gems / Dead), Pareto analysis, out-of-stock waste, category-level summary | [`product_performance.csv`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/abea3d7996b8a451f330dda845d546a864e50e73/product_performance.csv) |
| 07 |  [`sql/cohort_retention_analysis_postgres.sql`]( https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/f4d526057b9772aa81d04719fdbaf2186b2926a8/Cohort%20Analysis.sql) | Monthly cohort definition, retention matrix (Month 0 → N), purchase cohort, repeat purchase rate, best/worst cohort | [`cohort_retention.csv`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/abea3d7996b8a451f330dda845d546a864e50e73/cohort_retention.csv) |
| 08 |  [`sql/time_series_analysis_postgres.sql`]( https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/f4d526057b9772aa81d04719fdbaf2186b2926a8/Time%20Series%20Analysis.sql) | Daily/weekly/hourly patterns, peak hours, weekday vs weekend CVR, month-over-month change, anomaly flags | [`time_series_data.csv`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/abea3d7996b8a451f330dda845d546a864e50e73/time_series_data.csv) |
| 09 |  [`sql/category_analysis_postgres.sql`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/f4d526057b9772aa81d04719fdbaf2186b2926a8/Category%20Analysis.sql ) | Category tree hierarchy, per-category metrics, top/bottom 10 by CVR, cross-category browsing patterns | [`category_analysis.csv`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/abea3d7996b8a451f330dda845d546a864e50e73/category_analysis.csv) |
| 10 |   [`sql/simulated_ab_groups_postgres.sql`]( https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/f4d526057b9772aa81d04719fdbaf2186b2926a8/AB%20Test%20Data%20Preparation.sql) | 5 simulated A/B test group assignments (Morning/Evening, Single/Multi, Weekday/Weekend, Light/Heavy, Abandoner Return) | [`simulated_ab_groups_csv.png`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/5d44d634bf0d9fbfa8f7140de788660869c917ef/ab_test_data.png) |

---

## 🐍 Python Notebooks & Chart Outputs

> All notebooks are in the `python/` directory. Run `00_feature_engineering.ipynb` **FIRST** before any other notebook.

### Notebooks

| # | Notebook | Purpose | Key Analyses | Output |
|---|----------|---------|-------------|--------|
| 00 | [`python/features_engineer.ipynb`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/7cbcb47803a9118101dc0a69cefb2b04a61fd0b3/Notebook%2000%20Feature%20Engineering.ipynb) | Create 35+ engineered features used across all notebooks | Session-level features, user-level features, item-level features, time-based features, behavioral signal features | [`features_engineer.csv`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/6a19a7d3ab5506f5c536a46ab7d58cca438d2150/Notebook%2000%20Feature%20Engineering.ipynb) |
| 01 | [`python/probability_results.ipynb`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/7cbcb47803a9118101dc0a69cefb2b04a61fd0b3/Notebook%2001%20-%20%20Probability%20Analysis.ipynb) | Basic, conditional, Bayes theorem, and joint probability analysis | P(Purchase), P(Purchase\|AddToCart), P(Purchase\|3+ Views), P(Abandon\|Cart), Bayes: P(Buyer\|Heavy Viewer), joint probabilities | [`probability_results.csv`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/0c89753569d5cbcc5ca57b3ca38a60e0d12572c2/probability_results.csv) |
| 02 | [`python/Ecommerce_distribution_results.ipynb`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/7cbcb47803a9118101dc0a69cefb2b04a61fd0b3/Notebook%2002%20-%20Distribution%20Analysis.ipynb) | Distribution fitting and outlier detection | Views per user distribution, Poisson test (hourly events), Normal test (session lengths), Power Law test (item popularity), Z-score & IQR outlier detection | [`distribution_results.csv`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/0c89753569d5cbcc5ca57b3ca38a60e0d12572c2/distribution_results.csv) |
| 03 | [`python/Ecommerce_hypothesis_results.ipynb`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/7cbcb47803a9118101dc0a69cefb2b04a61fd0b3/Notebook%2003%20-%20Hypothesis%20Testing.ipynb) | 5 statistical hypothesis tests with H₀/H₁/conclusion | Independent t-test, Chi-Square, Two-Proportion Z-Test, Mann-Whitney U, One-Way ANOVA | [`hypothesis_results.csv`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/0c89753569d5cbcc5ca57b3ca38a60e0d12572c2/hypothesis_results.csv) |
| 04 | [`python/Ecommerce_ab_test_results.ipynb`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/7cbcb47803a9118101dc0a69cefb2b04a61fd0b3/Notebook%2004%20Simulated%20AB%20Testing.ipynb) | 5 simulated A/B tests with full statistical framework | Pre-test planning (baseline, MDE, sample size), 5 tests with z-test + CI, master summary table | [`ab_test_results.csv`](https://github.com/mojahid1252/Retailrocket-Ecommerce-Business-Analysis/blob/0c89753569d5cbcc5ca57b3ca38a60e0d12572c2/ab_test_results.csv) |

### Chart Outputs

> All charts are saved in the Notebook uploaded above the Python file . These are the visual outputs from Python notebooks. For Seeing Just click the above files.

| Chart | Source | Description |
|-------|--------|-------------|
| `distribution_plots.png` | Python Notebook 02 | Histograms with distribution overlays, Q-Q plots, box plots, log-scale plots |
| `hypothesis_results.png` | Python Notebook 03 | Test summary table, p-value comparison, effect size visualization |
| `ab_test_results.png` | Python Notebook 04 | CVR comparison bars, confidence interval plots, winner badges per test |

---

## 🔬 Python Statistical Analysis

### Hypothesis Testing Summary

| # | Test | Business Question | P-Value | Result | Business Conclusion |
|---|------|-------------------|---------|--------|---------------------|
| 1 | Independent t-test | Do buyers view more items than non-buyers? | < 0.001 | ✅ Reject H₀ | Viewing more = purchase signal → show more related products to engaged users |
| 2 | Chi-Square | Is purchase behavior independent of time of day? | 0.003 | ✅ Reject H₀ | Time-targeted campaigns will be effective |
| 3 | Two-Proportion Z-Test | Is weekday CVR different from weekend CVR? | 0.021 | ✅ Reject H₀ | Adjust ad budget allocation by day type |
| 4 | Mann-Whitney U | Do deeper sessions lead to higher conversion? | 0.009 | ✅ Reject H₀ | Keep users engaged longer with more recommendations |
| 5 | One-Way ANOVA | Do all categories receive equal engagement? | < 0.001 | ✅ Reject H₀ | Low-engagement categories need visibility boost campaigns |

### Simulated A/B Test Results

| Test | Control CVR | Treatment CVR | Relative Lift | p-value | Winner |
|------|-------------|---------------|---------------|---------|--------|
| Morning vs Evening | Morning | Evening | Higher | < 0.05 | 🏆 Evening |
| Single vs Multi-Session | Single | Multi | **3x** | < 0.05 | 🏆 Multi-Session |
| Weekday vs Weekend | Weekday | Weekend | Significant | < 0.05 | 🏆 Winner depends |
| Light vs Heavy Viewers | Light | Heavy | **Dramatic** | < 0.05 | 🏆 Heavy Viewers |
| Cart Abandoner Return | Never Returned | Returned Later | Higher | < 0.05 | 🏆 Returnees |

> ⚠️ **Disclaimer:** These are simulated experiments using behavioral/time-based splits - not real randomized controlled experiments. This retrospective simulation approach is standard practice in e-commerce analytics when true randomized experiments are unavailable. No users were randomly assigned during original data collection.

---



---

## 💡 Key Business Insights

> 🔍 **Finding 1:** 97%+ of visitors never purchase — the funnel is collapsing between View → Cart
> → **Impact:** Improving product page engagement with "Related Products" carousel and social proof can push users past the 3-event threshold where conversion probability jumps significantly

> 🔍 **Finding 2:** Cart abandonment rate is ~76.8% - 3 in 4 users who add to cart leave without buying
> → **Impact:** Triggering recovery notifications within 1 hour of abandonment can recover 5-8% of abandoned carts (industry benchmark), translating to ~1,750 additional purchases

> 🔍 **Finding 3:** Evening users (6PM-12AM) convert significantly higher than morning users (p < 0.05)
> → **Impact:** Shifting campaign budget to the 6PM-10PM window increases campaign ROI without additional spend — just better timing

> 🔍 **Finding 4:** Multi-session users are 3x more likely to purchase than single-session users
> → **Impact:** Retargeting single-session users within 24 hours with "Still thinking about it?" messaging can convert browsers into return visitors, dramatically lifting their purchase probability

> 🔍 **Finding 5:** Hidden Gem products exist — high CVR but critically low visibility
> → **Impact:** Featuring these products in "You Might Also Like" carousels unlocks untapped conversion potential at zero additional acquisition cost

> 🔍 **Finding 6:** Out-of-stock items are still receiving significant traffic through recommendations
> → **Impact:** Removing unavailable items from recommendation slots and redirecting traffic to available alternatives reduces wasted sessions and improves overall CVR

> 🔍 **Finding 7:** Deeper sessions convert significantly more (Mann-Whitney U, p < 0.05)
> → **Impact:** Showing more recommendations and keeping users engaged past the 3-event threshold directly correlates with higher purchase probability

> 🔍 **Finding 8:** Power Users drive majority of conversions but are a tiny % of total users
> → **Impact:** Building early identification model for Power User behavioral signals within first 2-3 sessions enables VIP personalization and retention strategies

> 🔍 **Finding 9:** Category engagement varies significantly (ANOVA, p < 0.001)
> → **Impact:** Low-engagement categories need content/UX audits and visibility boost campaigns; high-engagement categories should receive more inventory investment

> 🔍 **Finding 10:** Bounce users leave after just 1-2 events — landing page relevance is broken
> → **Impact:** Improving landing page relevance and first impression can reduce bounce rate, turning abandoned visits into browsing sessions

---

## 📊 Insight → Action Mapping

| # | Insight Found | Statistical Evidence | Recommended Action | Expected Impact |
|---|--------------|---------------------|--------------------|-----------------|
| 1 | 97% visitors never purchase | Funnel Analysis | Improve product page engagement with related items carousel | +CVR improvement |
| 2 | Cart abandonment at ~76.8% | SQL Cart Analysis | Trigger recovery notification 1hr after abandonment | Recover 5-8% abandoners |
| 3 | Evening users convert higher | A/B Test p < 0.05 | Shift campaign budget to 6PM-10PM window | Higher campaign ROI |
| 4 | Multi-session users convert 3x more | A/B Test p < 0.05 | Retarget single-session users within 24hrs | Convert browsers to buyers |
| 5 | Hidden gems getting zero traffic | Product Matrix | Feature high-CVR low-traffic items in carousels | Unlock untapped CVR |
| 6 | Out-of-stock items wasting traffic | Product Analysis | Remove unavailable items from all recommendation slots | Reduce wasted sessions |
| 7 | Deeper sessions = higher CVR | Mann-Whitney p < 0.05 | Show more recommendations past 3-event threshold | Increase session depth |
| 8 | Power Users drive majority of conversions | RFE Segmentation | Build early identification model for Power User signals | Personalization ROI |
| 9 | Category CVR varies significantly | ANOVA p < 0.001 | Audit low-CVR categories for content/UX issues | Category-level CVR lift |
| 10 | Bounce users leave after 1-2 events | Behavior Segmentation | Improve landing page relevance and first impression | Reduce bounce rate |

---

## 💰 Business Impact Estimation

> ⚠️ **Disclaimer:** Revenue figures are hypothetical estimates based on an assumed AOV of $35 USD. Actual impact depends on real pricing data which is not available in this dataset. These projections demonstrate analytical thinking — not real business forecasts.

### "What If CVR Improves by 1%?"

| CVR | Sessions (Total) | Purchase Events | Additional Revenue (Assumed) |
|-----|-------------------|-----------------|-------------------------------|
| **2.14%** (current) | 2,100,000 | 44,940 | Baseline |
| 2.64% (+0.5%) | 2,100,000 | 55,440 | +$367,500 |
| 3.14% (+1.0%) | 2,100,000 | 65,940 | +$735,000 |
| 4.14% (+2.0%) | 2,100,000 | 86,940 | +$1,470,000 |

### Where Can This +1% CVR Come From?

| Action | Mechanism | Est. CVR Impact |
|--------|-----------|-----------------|
| Cart Recovery Campaign | Industry benchmark: recovers 5-8% of abandoned carts | +0.08% |
| Evening Campaign Targeting | Shift 20% morning budget to evening peak hours | +0.15% |
| Hidden Gem Product Promotion | Expose high-CVR low-traffic items | +0.20% |
| Remove Out-of-Stock from Recommendations | Redirect wasted traffic to available alternatives | +0.25% |
| Multi-Session Retargeting | Push notification after 24h gap for returning users | +0.30% |
| **Combined Estimated Impact** | | **~+1.0% CVR** ✅ |

---


## ⚠️ Data Limitations (Honest Disclosure)

- **No real monetary values** in this dataset — all revenue projections are hypothetical
- **Segmentation uses behavioral signals** (not traditional RFM) - engagement proxy, not monetary value
- **A/B tests are simulated** (not real controlled experiments) - retrospective analysis, not randomized assignment
- **Price column is encoded** — not real currency, no monetary analysis performed
- **All value metrics = conversion-based proxy** - CVR is the primary success metric throughout
- **Assumed AOV of $35 USD** for impact estimation - clearly labeled as assumption

> This project values analytical integrity over inflated claims. Every limitation is disclosed upfront.

---

## 🚀 How to Use This Project

### Prerequisites

- [ ] Power BI Desktop installed (latest version)
- [ ] SQL Server / MySQL / PostgreSQL (for running SQL files)
- [ ] Python 3.8+ with Jupyter Notebook
- [ ] Git installed

### Steps

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/retail-rocket-analytics.git
cd retail-rocket-analytics
```

2. **Set up the database**
```sql
-- Create database and load raw CSVs
-- Run SQL files in order:
-- 01 → 02 → 03 → ... → 10
```

3. **Run Python notebooks (in order)**
```bash
# First: Generate features
jupyter notebook python/00_feature_engineering.ipynb

# Then run analysis notebooks
jupyter notebook python/01_probability_analysis.ipynb
jupyter notebook python/02_distribution_analysis.ipynb
jupyter notebook python/03_hypothesis_testing.ipynb
jupyter notebook python/04_simulated_ab_testing.ipynb
```

4. **Open Power BI Dashboard**
```
Open powerbi/retail_rocket_dashboard.pbix
→ Data will load from processed/ CSV files
→ Refresh if needed: Home → Refresh
→ Point to your local data/processed/ folder
```

5. **Explore the dashboard**
```
Page 1: Executive Overview — Start here for the big picture
Page 2: Funnel & Drop-off — Where users leave
Page 3: Cart Abandonment — Why carts are abandoned
Page 4: Behavior Segmentation — Who your users are
Page 5: Product Performance — What's working and what's not
Page 6: Cohort Retention — How well users return
Page 7: Statistical Results — What's statistically proven
Page 8: Time & Behavioral Patterns — When conversion peaks
```
---

## 👨‍💻 About The Analyst

**[Mozahidul Islam]**
Data Analyst | E-Commerce Analytics & BI Specialist

I build end-to-end analytics solutions that turn raw operational data into executive-grade dashboards - SQL data warehousing, Power BI semantic modeling, DAX measures, and the business storytelling that ties it all together.

- 📧 **Email:** [mojahidulislam101010@gmail.com]
- 💼 **LinkedIn:** [https://www.linkedin.com/in/mozahidul-islam-453662380/]
- 🌐 **Portfolio:** 
- 📊 **Fiverr / Upwork:** 

---

## 🤝 Let's Work Together

Are you a financial services business looking to:

→ **Democratize data access** across product, risk, and marketing teams?
→ **Identify revenue concentration risks** before they become problems?
→ **Segment customers** for targeted acquisition and retention?
→ **Make data-driven decisions** instead of gut-driven ones?

**I can help. Let's talk.**

[📩 Contact Me](mailto:mojahidulislam101010@gmail.com) · [📅 Book a Call](https://calendly.com/my-link)

---


## ⚙️ Feature Engineering Overview

This project includes **35+ engineered features** across 5 categories, created in `python/00_feature_engineering.ipynb`:

| Feature Category | Key Features | Purpose |
|-----------------|-------------|---------|
| **Session-Level** | session_duration_mins, events_per_session, event_diversity_score, session_outcome | Capture each visit's engagement quality |
| **User-Level** | total_sessions, view_to_cart_ratio, cart_to_purchase_ratio, purchase_probability_score, user_segment | Profile user behavior across all visits |
| **Item-Level** | item_view_to_cart_rate, item_cvr, item_quadrant, item_availability | Classify product performance and potential |
| **Time-Based** | is_evening, is_peak_hour, is_weekend, days_from_start | Capture temporal conversion patterns |
| **Behavioral Signals** | cart_without_purchase, multi_category_browser, return_visitor, view_depth_before_cart, abandonment_flag | Predict purchase intent from behavior |

---

<div align="center">

---

⭐ **If this project helped you, give it a star!**

![GitHub stars](https://img.shields.io/github/stars/yourusername/retail-rocket-analytics?style=social)
![GitHub forks](https://img.shields.io/github/forks/yourusername/retail-rocket-analytics?style=social)
![GitHub watchers](https://img.shields.io/github/watchers/yourusername/retail-rocket-analytics?style=social)

---

*Built with ❤️ by [Mozahid | 2025*

</div>
