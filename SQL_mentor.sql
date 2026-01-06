create database sql_mentor_dataset

use sql_mentor_dataset
select * from user_sub_sql_mentor06nov

--- Q1. List All Distinct Users and Their Stats
select username,count(id) as total_submissions,sum(points) as point_earned from user_sub_sql_mentor06nov
group by username
order by total_submissions

--- Q2: Calculate the Daily Average Points for Each User
select 
cast(submitted_at as date) as day ,
username,
avg(points) as  daily_ave_points
from user_sub_sql_mentor06nov
group by cast(submitted_at as date),username
order by username;

---Q3: Find the Top 3 Users with the Most Correct Submissions for Each Day
WITH daily_submissions AS (
    SELECT 
        CAST(submitted_at AS date) AS daily,
        username,
        SUM(CASE WHEN points > 0 THEN 1 ELSE 0 END) AS correct_submissions
    FROM user_sub_sql_mentor06nov
    GROUP BY CAST(submitted_at AS date), username
),
users_rank AS (
    SELECT 
        daily,
        username,
        correct_submissions,
        DENSE_RANK() OVER (
            PARTITION BY daily 
            ORDER BY correct_submissions DESC
        ) AS rnk
    FROM daily_submissions
)
SELECT 
    daily,
    username,
    correct_submissions
FROM users_rank
WHERE rnk <= 3
ORDER BY daily, rnk;


---Q4: Find the Top 5 Users with the Highest Number of Incorrect Submissions
SELECT TOP 5 username,
COUNT(*) AS incorrect_submissions
FROM user_sub_sql_mentor06nov
WHERE points <= 0
GROUP BY username
ORDER BY incorrect_submissions DESC;

---Q5: Find the Top 10 Performers for Each Week
WITH weekly_points AS (
    SELECT
        DATEPART(YEAR, submitted_at) AS year,
        DATEPART(WEEK, submitted_at) AS week_no,
        username,
        SUM(points) AS total_points_earned
    FROM user_sub_sql_mentor06nov
    GROUP BY
        DATEPART(YEAR, submitted_at),
        DATEPART(WEEK, submitted_at),
        username
),
ranked_users AS (
    SELECT
        year,
        week_no,
        username,
        total_points_earned,
        DENSE_RANK() OVER (
            PARTITION BY year, week_no
            ORDER BY total_points_earned DESC
        ) AS rnk
    FROM weekly_points
)
SELECT
    year,
    week_no,
    username,
    total_points_earned
FROM ranked_users
WHERE rnk <= 10
ORDER BY year, week_no, rnk;
