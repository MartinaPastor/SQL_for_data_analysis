/* Calculating churn rates for two segments of users
This project is part of the open-ended exercise regarding churn rates
*/

-- 1. Get a sense of the data

SELECT *
FROM subscriptions
LIMIT 100;

-- 2. Determine the range of months of data provided.

SELECT MIN(subscription_start) AS first_month,
       MAX(subscription_start) AS last_month
FROM subscriptions;

-- 3. Prepare a temporary table with the info necessary to calculate the churn rate

WITH months AS (   --temporary table addressing the months of interest
  SELECT
  '2017-01-01' AS first_day,
  '2017-01-31' AS last_day
  UNION
  SELECT
  '2017-02-01' AS first_day,
  '2017-02-28' AS last_day
  UNION
  SELECT
  '2017-03-01' AS first_day,
  '2017-03-31' AS last_day
),
cj AS (         -- cross join between months and subscriptions
  SELECT *
  FROM subscriptions
  CROSS JOIN months
),
status AS       -- temp table hosting several info
(SELECT id,
        first_day as month,
        CASE
        WHEN (
          subscription_start < first_day)
          AND (
          segment = 87)
          AND (
          subscription_end > first_day
          OR subscription_end IS NULL
            ) THEN 1
          ELSE 0
          END AS is_active_87,         -- active 87 segment per month
        CASE
        WHEN (
          subscription_start < first_day)
          AND (
          segment = 30)
          AND (
          subscription_end > first_day
          OR subscription_end IS NULL
            ) THEN 1
          ELSE 0
          END AS is_active_30,          -- active 30 segment per month
       CASE
       WHEN (
          subscription_end BETWEEN first_day AND last_day)
          AND (
          segment = 87
            ) THEN 1
          ELSE 0
          END as is_cancelled_87,        -- cancelled 87 segment per month
        CASE
        WHEN (
          subscription_end BETWEEN first_day AND last_day)
          AND (
          segment = 30
            ) THEN 1
          ELSE 0
          END as is_cancelled_30         -- -- cancelled 30 segment per month
          FROM cj
)
SELECT *
FROM status;

-- 4. Sum active and cancelled values per month

SELECT month,
       SUM(active87) AS sum_active_87,
       SUM(active30) AS sum_active_30,
       SUM(cancelled87) AS sum_cancelled_87,
       SUM(cancelled30) AS sum_cancelled_30
FROM status
GROUP BY 1;

-- 5. Find churn rate;

SELECT month,
       1.0 * sum_cancelled_87/sum_active_87
       AS churn_rate87,
       1.0 * sum_cancelled_30/sum_active_30
       AS churn_rate30
FROM status_aggregate
GROUP BY 1;

-- OR add segment as a discriminant factor

WITH months AS (
  SELECT
  '2017-01-01' AS first_day,
  '2017-01-31' AS last_day
  UNION
  SELECT
  '2017-02-01' AS first_day,
  '2017-02-28' AS last_day
  UNION
  SELECT
  '2017-03-01' AS first_day,
  '2017-03-31' AS last_day
),
cj AS (
  SELECT *
  FROM subscriptions
  CROSS JOIN months
),
status AS (
SELECT id,
        first_day as month,
        segment,
        CASE
        WHEN (
          subscription_start < first_day)
          AND (
          subscription_end > first_day
          OR subscription_end IS NULL
            ) THEN 1
          ELSE 0
          END AS active,
        CASE
        WHEN (
          subscription_end BETWEEN first_day AND last_day)
          THEN 1
          ELSE 0
          END as cancelled
          FROM cj
),
status_aggregate AS (
SELECT month,
       segment,
       SUM(active) AS sum_active,
       SUM(cancelled) AS sum_cancelled
       FROM status
       GROUP BY 1, 2   -- sum grouped by month and segment 
)
SELECT month,
       segment,
       1.0 * sum_cancelled/sum_active
       AS churn_rate
FROM status_aggregate
GROUP BY 1,2;
