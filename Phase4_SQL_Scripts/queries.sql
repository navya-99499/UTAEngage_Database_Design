-- 1. For each day of the week, what is the average listening hours spent by a patron?
SET DEFINE OFF;
SET LINESIZE 200
SET PAGESIZE 100
COLUMN "day_of_week" FORMAT A12
COLUMN "avg_listening_hours_per_patron" FORMAT 9990.99

SELECT
    -- Extracts day name from timestamp
    TO_CHAR(l.listenTimestamp, 'DAY') AS day_of_week,
    -- Converts avg minutes to hours
    ROUND(AVG(l.duration)/60, 2) AS avg_listening_hours_per_patron
FROM 
    DASC5306_Fall25_S001_T8_Listens l
JOIN 
    DASC5306_Fall25_S001_T8_Patron p
ON 
    l.patronId = p.patronId
GROUP BY 
    TO_CHAR(l.listenTimestamp, 'DAY'),
    -- Ensure correct weekday order (1–7)
    TO_CHAR(l.listenTimestamp, 'D')
ORDER BY 
    TO_CHAR(l.listenTimestamp, 'D');


-- 2. List the top 10 artists who on an average have received the most number of likes across
-- all their podcast episodes uploaded in 2024.
COLUMN "artist_ID" FORMAT A15

SELECT 
    a.artist_ID
FROM 
    DASC5306_Fall25_S001_T8_Artist a
    JOIN DASC5306_Fall25_S001_T8_Creates_Uploaded_ArtEpi c
        ON a.artist_ID = c.artist_ID
    JOIN DASC5306_Fall25_S001_T8_Episode e
        ON c.podcast_ID = e.podcast_ID
       AND c.episodeNumber = e.episodeNumber
WHERE 
    -- Filter for episodes uploaded in 2024
    EXTRACT(YEAR FROM e.upload_date_time) = 2024
GROUP BY 
    a.artist_ID
ORDER BY AVG(e.likes) DESC
-- Retrieve top 10 artists
FETCH FIRST 10 ROWS ONLY;


/*
3. For each nationality and year of birth, list the most popular theme along with its average
episode duration. The popularity of a theme is quantified based on the total number of
views the related podcast receives.
*/
COLUMN "nationality" FORMAT A15
COLUMN "yob" FORMAT 9999
COLUMN "theme" FORMAT A25
COLUMN "avg_duration" FORMAT 999.99

SELECT nationality,
       yob,
       theme,
       avg_duration
FROM (
    SELECT s.nationality,
            -- Calculate year of birth
           (EXTRACT(YEAR FROM SYSDATE) - s.age) AS yob,
           t.theme,
           SUM(podcast_views.total_views) AS theme_views,
           ROUND(AVG(e.duration), 2) AS avg_duration,
           RANK() OVER (
               PARTITION BY s.nationality, (EXTRACT(YEAR FROM SYSDATE) - s.age)
               ORDER BY SUM(podcast_views.total_views) DESC
            -- Rank themes by popularity within group
           ) AS rnk
    FROM DASC5306_Fall25_S001_T8_Student s
    JOIN DASC5306_Fall25_S001_T8_Patron p
         ON s.netID = p.patronId
    JOIN DASC5306_Fall25_S001_T8_Listens l
         ON p.patronId = l.patronId
    JOIN DASC5306_Fall25_S001_T8_Episode e
         ON l.episodeNumber = e.episodeNumber
        AND l.podcast_ID = e.podcast_ID
    JOIN DASC5306_Fall25_S001_T8_Theme t
         ON e.podcast_ID = t.podcast_ID
    JOIN (
        --  Pre-aggregate views at podcast level
        SELECT podcast_ID, SUM(views) AS total_views
        FROM DASC5306_Fall25_S001_T8_Episode
        GROUP BY podcast_ID
    ) podcast_views
         ON t.podcast_ID = podcast_views.podcast_ID
    GROUP BY s.nationality, (EXTRACT(YEAR FROM SYSDATE) - s.age), t.theme
)
-- Keep only top-ranked (most popular) theme
WHERE rnk = 1
ORDER BY nationality, yob;


/*
4. List the name, theme, number of episodes, and the average number of views per episode
for the podcasts that have only been listened to by the students from the 'CSE'
department enrolled after July 2023. Order the list in the decreasing order of the average
number of views per episode.
*/
COLUMN "podcast_name" FORMAT A30
COLUMN "theme" FORMAT A20
COLUMN "num_episodes" FORMAT 999
COLUMN "avg_views_per_episode" FORMAT 9990.99

SELECT p.name AS podcast_name,
       t.theme,
       COUNT(e.episodeNumber) AS num_episodes,
       ROUND(AVG(e.views), 2) AS avg_views_per_episode
FROM DASC5306_Fall25_S001_T8_Podcast p
JOIN DASC5306_Fall25_S001_T8_Theme t
     ON p.podcast_ID = t.podcast_ID
JOIN DASC5306_Fall25_S001_T8_Episode e
     ON p.podcast_ID = e.podcast_ID
JOIN DASC5306_Fall25_S001_T8_Listens l
     ON e.podcast_ID = l.podcast_ID
    AND e.episodeNumber = l.episodeNumber
JOIN DASC5306_Fall25_S001_T8_Patron pa
     ON l.patronId = pa.patronId
JOIN DASC5306_Fall25_S001_T8_Student s
     ON pa.patronId = s.netID
-- Only CSE students
WHERE s.enrolled_dept = 'CSE'   
  -- Enrolled after July 2023
  AND s.date_of_enrollment > TO_DATE('2023-07-31', 'YYYY-MM-DD')
  AND NOT EXISTS (
        SELECT 1
        FROM DASC5306_Fall25_S001_T8_Listens l2
        JOIN DASC5306_Fall25_S001_T8_Patron pa2
             ON l2.patronId = pa2.patronId
        JOIN DASC5306_Fall25_S001_T8_Student s2
             ON pa2.patronId = s2.netID
        WHERE l2.podcast_ID = p.podcast_ID
          AND (s2.enrolled_dept <> 'CSE'
               OR s2.date_of_enrollment <= TO_DATE('2023-07-31', 'YYYY-MM-DD'))
  )
GROUP BY p.name, t.theme
ORDER BY avg_views_per_episode DESC;




/*
5. Who are the student subscribers who have listened to every video episode of the
technology or educational themed podcasts that have the phrase 'large language model'
appear somewhere in the description? Find their name, GPA, and email ID.
*/
COLUMN "name" FORMAT A25
COLUMN "gpa" FORMAT 999.99
COLUMN "email" FORMAT A40

WITH qualifying_podcasts AS (
  -- Get all podcasts matching description & theme
  SELECT DISTINCT p.podcast_ID 
  FROM DASC5306_Fall25_S001_T8_Podcast p
  JOIN DASC5306_Fall25_S001_T8_Theme t
    ON t.podcast_ID = p.podcast_ID
  WHERE LOWER(p.description) LIKE '%large language model%'
    AND t.theme IN ('technology', 'educational')
),
video_episodes AS (
  -- Extract all video-format episodes
  SELECT e.podcast_ID, e.episodeNumber    
  FROM DASC5306_Fall25_S001_T8_Episode e
  JOIN qualifying_podcasts qp
    ON qp.podcast_ID = e.podcast_ID
  WHERE LOWER(e.format) = 'video'
),
candidates AS (
   -- Select all potential student candidates
  SELECT s.netID, s.username, s.cumulativeGPA, s.email   
  FROM DASC5306_Fall25_S001_T8_Student s
  JOIN DASC5306_Fall25_S001_T8_Patron pa
    ON pa.patronId = s.netID
)
SELECT c.username AS name,
       c.cumulativeGPA AS gpa,
       c.email
FROM candidates c
-- must be subscribed to every qualifying podcast
WHERE NOT EXISTS (
  -- Check if candidate missed subscription to any qualifying podcast
  SELECT 1    
  FROM qualifying_podcasts q
  WHERE NOT EXISTS (
    SELECT 1
    FROM DASC5306_Fall25_S001_T8_Subscribes sub
    WHERE sub.patronId = c.netID
      AND sub.podcast_ID = q.podcast_ID
  )
)
-- must have listened to every video episode of those podcasts
AND NOT EXISTS (
   -- Check if candidate missed listening to any video episode
  SELECT 1   
  FROM video_episodes ve
  WHERE NOT EXISTS (
    SELECT 1
    FROM DASC5306_Fall25_S001_T8_Listens l
    WHERE l.patronId = c.netID
      AND l.podcast_ID = ve.podcast_ID
      AND l.episodeNumber = ve.episodeNumber
  )
)
ORDER BY gpa DESC, name;

/*
6.For each product type advertised, what is the average revenue generated
per department, and which department brings the maximum revenue?
*/
COLUMN "product_type" FORMAT A50
COLUMN "enrolled_dept" FORMAT A20
COLUMN "avg_revenue" FORMAT 99990.99
WITH dept_revenue AS (
    SELECT adv.product_type,
           s.enrolled_dept,
           -- Average revenue (display cost)
           ROUND(AVG(d.cost), 2) AS avg_revenue      
    FROM DASC5306_Fall25_S001_T8_Advertisement adv
    JOIN DASC5306_Fall25_S001_T8_DisplayedIn d
         ON adv.advertiserID = d.advertiserID
        AND adv.adId = d.adId
    JOIN DASC5306_Fall25_S001_T8_Listens l
         ON d.podcast_ID = l.podcast_ID
        AND d.episodeNumber = l.episodeNumber
    JOIN DASC5306_Fall25_S001_T8_Patron p
         ON l.patronId = p.patronId
    JOIN DASC5306_Fall25_S001_T8_Student s
         ON p.patronId = s.netID
    GROUP BY adv.product_type, s.enrolled_dept
)
SELECT product_type,
       enrolled_dept,
       avg_revenue
FROM (
    SELECT product_type,
           enrolled_dept,
           avg_revenue,
           RANK() OVER (PARTITION BY product_type ORDER BY avg_revenue DESC) AS rnk
    FROM dept_revenue
)
-- Choose top-performing department per product type
WHERE rnk = 1     
ORDER BY avg_revenue DESC;

/*
7. Which advertisers have continuously increased their ad spending
(display cost + rate per view) every quarter, and what is the growth rate?
*/
COLUMN "advertiserID" FORMAT A10
COLUMN "name" FORMAT A25
COLUMN "first_quarter_spend" FORMAT 999999.99
COLUMN "last_quarter_spend" FORMAT 999999.99
COLUMN "quarters" FORMAT 999
COLUMN "cagr_percent" FORMAT 999.99

WITH base AS (
  SELECT d.advertiserID,
         TRUNC(d.timestamp, 'Q') AS qtr_start,
         -- Total spend per quarter
         SUM(d.cost + (adv.rate_per_view * e.views)) AS spend_qtr    
  FROM DASC5306_Fall25_S001_T8_DisplayedIn d
  JOIN DASC5306_Fall25_S001_T8_Advertiser adv
    ON adv.advertiserID = d.advertiserID
  JOIN DASC5306_Fall25_S001_T8_Episode e
    ON e.podcast_ID = d.podcast_ID
   AND e.episodeNumber = d.episodeNumber
  GROUP BY d.advertiserID, TRUNC(d.timestamp, 'Q')
),
seq AS (
  SELECT b.*,
         ROW_NUMBER() OVER (PARTITION BY advertiserID ORDER BY qtr_start) AS rn,
         COUNT(*) OVER (PARTITION BY advertiserID) AS cnt,
         LAG(spend_qtr) OVER (PARTITION BY advertiserID ORDER BY qtr_start) AS prev_spend
  FROM base b
),
increasing AS (
  SELECT advertiserID
  FROM seq
  GROUP BY advertiserID
  HAVING MIN(
           CASE
             WHEN prev_spend IS NULL THEN 1
             WHEN spend_qtr > prev_spend THEN 1
             ELSE 0
           END
         ) = 1
     AND MAX(cnt) >= 2
)
SELECT adv.advertiserID,
       adv.name,
       ROUND(
         (POWER(
            (MAX(CASE WHEN s.rn = s.cnt THEN s.spend_qtr END) /
             NULLIF(MIN(CASE WHEN s.rn = 1 THEN s.spend_qtr END), 0)),
            1 / (MAX(s.cnt) - 1)
          ) - 1) * 100
          -- Compound Annual Growth Rate %
       , 2) AS cagr_percent      
FROM seq s
JOIN increasing i
  ON i.advertiserID = s.advertiserID
JOIN DASC5306_Fall25_S001_T8_Advertiser adv
  ON adv.advertiserID = s.advertiserID
GROUP BY adv.advertiserID, adv.name
-- Highest CAGR first
ORDER BY cagr_percent DESC NULLS LAST;  
