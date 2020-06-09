/* Not featuring any descriptive analysis

DATA distributed across three tables

Given a Home Try-On Funnel composed of 2 stages (a quiz and a try-on stage
the latter featuring an A/B test where half the users gets to try on at home
3 pairs of glasses while the other half 5), having  user_id be the same across
the three tables*/

-- 1.  get a sense of the data;
SELECT * FROM quiz
 LIMIT 5;

 SELECT * FROM home_try_on
 LIMIT 5;

 SELECT * FROM purchase
 LIMIT 5;

-- 2. Which distinct style featured more at the quiz and purchase stages;

SELECT DISTINCT style,
       1.0 * COUNT(*)/
       (SELECT COUNT(*) FROM quiz
       ) AS 'percentage'
FROM quiz
GROUP BY 1;

-- 3. Which is the most popular colour at the quiz and purchase stages;

SELECT color, COUNT(*)
FROM quiz
GROUP BY 1
ORDER BY 2 DESC;

-- 4. Number of purchases per price range;

SELECT
  CASE
  WHEN price <= 60 THEN 'cheap'
  WHEN price BETWEEN 60 AND 99 THEN 'moderate'
  ELSE 'expensive'
  END AS 'price_range',
  COUNT(*)
FROM purchase
GROUP BY 1;

-- 5. What are the 3 most popular items (or models, fit, etc);

SELECT 	product_id, COUNT(*)
FROM purchase
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3
;

-- 6. Unite everything into one new table;

SELECT q.user_id AS 'id',
         q.fit AS 'fit',
         q.shape AS 'shape',
         h.user_id IS NOT NULL AS 'try_On',
         p.user_id IS NOT NULL AS 'purchase',
         h.number_of_pairs AS 'n_pairs',
         p.model_name AS 'model',
         p.price AS 'price'
FROM quiz q
LEFT JOIN purchase p
  ON q.user_id = p.user_id
LEFT JOIN home_try_on h
  ON q.user_id = h.user_id
;

-- 7. what are the conversion rates across the tables;

WITH funnels AS(
  SELECT DISTINCT q.user_id,
   h.number_of_pairs AS 'n_pairs',
   h.user_id IS NOT NULL AS 'home_tryOn',
   p.user_id IS NOT NULL AS 'purchase'
   FROM quiz q
   LEFT JOIN home_try_on h
      ON q.user_id = h.user_id
   LEFT JOIN purchase p
      ON p.user_id = q.user_id
)
SELECT COUNT(user_id) AS 'total_users',
      (SELECT COUNT(*) FROM funnels
      WHERE n_pairs IS NULL) AS 'only_quiz',
       SUM(home_try_on) AS 'n_tryOn',
       SUM(purchase) AS 'n_purchase',
       1.0 * SUM(home_tryOn)/COUNT(user_id) AS 'quiz_to_tryON',
       1.0 * SUM(purchase)/COUNT(user_id) AS 'quiz_to_purchase'
FROM funnels
;

-- 8. find out whether users who get more pairs are more likely to make a purchase;

WITH funnels AS(
  SELECT DISTINCT q.user_id,
   h.number_of_pairs AS 'n_pairs',
   p.user_id IS NOT NULL AS 'purchase'
FROM quiz q
LEFT JOIN home_try_on h
   ON q.user_id = h.user_id
LEFT JOIN purchase p
   ON p.user_id = q.user_id
)
SELECT COUNT(*) AS 'n_users',
    (SELECT COUNT(*) FROM funnels
     WHERE purchase = 1
    ) AS 'n_buyers',
    1.0 * COUNT(
      CASE
      WHEN n_pairs LIKE '3%' AND purchase = 1 THEN user_id
      END
    )/COUNT(*) AS '3_pairs_buyers',
   1.0* COUNT(
      CASE
      WHEN n_pairs LIKE '5%' AND purchase = 1 THEN user_id
      END
    )/COUNT(*) AS'5_pairs_buyers'
FROM funnels
;
