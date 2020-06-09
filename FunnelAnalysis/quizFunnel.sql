/* Not featuring any descriptive analysis
   DATA for quiz funnel
*/

-- 1. get a sense of the data

SELECT *
FROM survey
LIMIT 10;

/* three columns: question, user_id, response */

-- 2. How many people took the survey?

SELECT COUNT(DISTINCT user_id)
FROM survey;

-- 3. see number of responses per question with and without percentage

SELECT question,
   COUNT(DISTINCT user_id)
FROM survey
GROUP BY 1;

SELECT question, COUNT(DISTINCT user_id) AS 'n_users',
    1.0 * COUNT(DISTINCT user_id)/(SELECT COUNT(DISTINCT user_id) FROM survey)
    AS 'PERCENTAGE'
FROM survey
GROUP BY 1;

-- 4. Search based on different gender wear

SELECT COUNT(
    CASE
    WHEN response LIKE 'Men%' THEN user_id
    END
  ) AS 'mens_wear',
  COUNT(
    CASE
    WHEN response LIKE 'Women%' THEN user_id
    END
  ) AS 'womens_wear'
FROM survey;

-- 5. General prefence of item per question

SELECT question,
       COUNT(response) AS 'num',
       response
  FROM survey
GROUP BY 3
ORDER BY 1;

-- 6. Preference of item based on gender
  -- To extend the analysis to other criteria change the LIKE specification

WITH surveyW AS (
      SELECT DISTINCT user_id AS 'id'
      FROM survey
      WHERE response LIKE "%Women%"
  )
SELECT question,
       COUNT(response) AS 'num',
       response
  FROM survey
    JOIN surveyW ON survey.user_id = surveyW.id
GROUP BY 3
ORDER BY 1;
