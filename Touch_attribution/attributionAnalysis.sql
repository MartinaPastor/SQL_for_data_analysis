/* Brief touch attribution analysis
The attributes are id, timestamp, page_name, utm_source, utm_campaign.
Data available on Codecademy
*/

-- 1. Explore the data;

SELECT *
FROM page_visits
LIMIT 100;

-- 2. Find which pages are available;

SELECT DISTINCT page_name
FROM page_visits;

-- 3. Find which sources and campaigns are used;

SELECT DISTINCT utm_campaign, utm_source
FROM page_visits;

SELECT COUNT(DISTINCT utm_source) n_sources,
       COUNT(DISTINCT utm_campaign) n_campaigns
FROM page_visits;

-- 4. Find how many user have been targeted;

SELECT COUNT(DISTINCT user_id)
FROM page_visits;

-- 5. Find the typical users journey;

SELECT page_name, COUNT(DISTINCT user_id)
FROM page_visits
GROUP BY 1;

-- 6. Find how many visitors made a purchase;

SELECT COUNT(*)
FROM page_visits
WHERE page_name LIKE '%purchase%'
;

-- 7. Display first and last touch in one table with attributed;

WITH first_last_touch AS (
  SELECT
    user_id,
    MIN(timestamp) as first_touch,
    MAX(timestamp) as last_touch
  FROM page_visits
  GROUP BY 1
),
ft AS (                                -- first touch data
  SELECT
    fl.user_id,
    fl.first_touch,
    pv.utm_source,
    pv.utm_campaign
  FROM first_last_touch fl
  JOIN page_visits pv
    ON fl.user_id = pv.user_id
    AND fl.first_touch = pv.timestamp
),
lt AS (                                -- last touch data
  SELECT
    fl.user_id,
    fl.last_touch,
    pv.utm_source,
    pv.utm_campaign
  FROM first_last_touch fl
  JOIN page_visits pv
  ON fl.user_id = pv.user_id
  AND fl.last_touch = pv.timestamp
),
temp_join AS (                        -- temp_join of first and last touch data
  SELECT
  ft.user_id AS id,
  ft.first_touch AS first_touch,
  ft.utm_source AS ft_utm_s,          -- first_touch UTM source
  ft.utm_campaign AS ft_utm_c,        -- first_touch UTM campaign
  lt.last_touch AS last_touch,
  lt.utm_source AS lt_utm_s,          -- last_touch UTM cource
  lt.utm_campaign AS lt_utm_c         -- last_touch UTM campaign
FROM ft
JOIN lt
  ON ft.user_id = lt.user_id
)
SELECT *
FROM temp_join
;

-- 8. Find the relation between campaing and first/last touch;

SELECT
  ft_utm_s, -- can be replaced by lt data
  ft_utm_c,
  COUNT(*)
FROM temp_join
GROUP BY 1, 2
ORDER BY 3 DESC;
;

-- 9. Find how many last_touch are at the purchase stage;

WITH lt AS (
  SELECT user_id,
         page_name,
         MAX(timestamp) AS last_touch
  FROM page_visits
  GROUP BY user_id)
SELECT COUNT(*)
FROM lt
WHERE page_name LIKE '%purchase%'
;

-- 10. Find which last_touch advertisment lead to purchase the most;

WITH last_touch AS (
  SELECT
    user_id,
    page_name,
    MAX(timestamp) as last_touch
  FROM page_visits
  GROUP BY 1
),
ltd AS (                                -- last touch data
  SELECT
    lt.user_id AS id,
    lt.page_name AS page_name,
    lt.last_touch AS last_touch,
    pv.utm_source AS utm_s,
    pv.utm_campaign AS utm_c
  FROM last_touch lt
  JOIN page_visits pv
    ON lt.user_id = pv.user_id
    AND lt.last_touch = pv.timestamp
)
SELECT utm_c, COUNT(*)
FROM ltd
WHERE page_name LIKE '%purchase%'
GROUP BY 1
ORDER BY 2 DESC
;

-- 11. Find which initial first_touch campaign ended with the most purchases

WITH first_last_touch AS (
  SELECT
    user_id,
    MIN(timestamp) as first_touch,
    MAX(timestamp) as last_touch
  FROM page_visits
  GROUP BY 1
),
ft AS (                                -- first touch data
  SELECT
    fl.user_id,
    fl.first_touch,
    pv.page_name,
    pv.utm_source,
    pv.utm_campaign
  FROM first_last_touch fl
  JOIN page_visits pv
    ON fl.user_id = pv.user_id
    AND fl.first_touch = pv.timestamp
),
lt AS (                                -- last touch data
  SELECT
    fl.user_id,
    fl.last_touch,
    pv.utm_source,
    pv.utm_campaign
  FROM first_last_touch fl
  JOIN page_visits pv
    ON fl.user_id = pv.user_id
    AND fl.last_touch = pv.timestamp
  WHERE pv.page_name LIKE '%purchase%'
),
temp_join AS (                        -- temp_join of first and last touch data
  SELECT
  ft.user_id AS id,
  ft.first_touch AS first_touch,
  ft.utm_source AS ft_utm_s,          -- first_touch UTM source
  ft.utm_campaign AS ft_utm_c,        -- first_touch UTM campaign
  lt.last_touch AS last_touch,
  lt.utm_source AS lt_utm_s,          -- last_touch UTM cource
  lt.utm_campaign AS lt_utm_c         -- last_touch UTM campaign
FROM ft
JOIN lt
  ON ft.user_id = lt.user_id
)
SELECT ft_utm_c, COUNT(*)
FROM temp_join
GROUP BY 1
ORDER BY 2 DESC
;

-- 12. Find how many first touch each campaign responsible for;

SELECT lt_utm_c, COUNT(*)
FROM temp_join
GROUP BY 1
ORDER BY 2 DESC
;
