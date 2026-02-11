CREATE DATABASE ab_testing_db;
USE ab_testing_db;

SELECT COUNT(*) FROM ab_test_raw;
SELECT * FROM ab_test_raw LIMIT 10;

SHOW DATABASES;

GRANT ALL PRIVILEGES ON ab_testing_db.* TO 'project_user'@'localhost';
FLUSH PRIVILEGES;

SELECT COUNT(*) FROM ab_test_raw;
SELECT * FROM ab_test_raw LIMIT 10;

CREATE TABLE users_dim (
    user_id INT PRIMARY KEY,
    region VARCHAR(50),
    customer_segment VARCHAR(50)
);

INSERT INTO users_dim (user_id, region, customer_segment)
SELECT DISTINCT
    user_id,
    region,
    customer_segment
FROM ab_test_raw;

select * from users_dim;

ALTER TABLE ab_test_raw
CHANGE COLUMN `group` experiment_group CHAR(1);

DESCRIBE ab_test_raw;

CREATE TABLE session_dim (
    session_id INT PRIMARY KEY,
    user_id INT,
    experiment_group CHAR(1),
    device_type VARCHAR(50),
    traffic_source VARCHAR(50),
    session_time_sec INT,
    num_items_viewed INT,
    CONSTRAINT fk_sessionsdim_userid

        FOREIGN KEY (user_id)
        REFERENCES users_dim(user_id)
);
INSERT INTO session_dim (
    session_id,
    user_id,
    experiment_group,
    device_type,
    traffic_source,
    session_time_sec,
    num_items_viewed
)
SELECT DISTINCT
    session_id,
    user_id,
    experiment_group,
    device_type,
    traffic_source,
    session_time_sec,
    num_items_viewed
FROM ab_test_raw;

select * from session_dim;

CREATE TABLE transaction_fact (
    transaction_id INT PRIMARY KEY,
    session_id INT,
    revenue DECIMAL(10,2),
    conversion TINYINT,
    payment_method VARCHAR(50),
    CONSTRAINT fk_transactionfact_sessionid
        FOREIGN KEY (session_id)
        REFERENCES session_dim(session_id)
);

INSERT INTO transaction_fact (
    transaction_id,
    session_id,
    revenue,
    conversion,
    payment_method
)
SELECT DISTINCT
    transaction_id,
    session_id,
    revenue,
    conversion,
    payment_method
FROM ab_test_raw
WHERE transaction_id IS NOT NULL;

select *from transaction_fact;
select * from users_dim;
select * from session_dim;

SELECT
    u.region,
    s.experiment_group,
    COUNT(t.transaction_id) AS total_orders,
    ROUND(SUM(t.revenue),2) AS total_revenue
FROM users_dim u
JOIN session_dim s
    ON u.user_id = s.user_id
JOIN transaction_fact t
    ON s.session_id = t.session_id
GROUP BY u.region, s.experiment_group;


EASY LEVEL (5 QUESTIONS)

Focus: joins, group by, basic aggregations


What we are trying to get:
Which A/B group generated more total revenue?

Concepts: JOIN, GROUP BY, SUM;

EASY 1: Total revenue by experiment group;
SELECT
    s.experiment_group,
    ROUND(SUM(t.revenue), 2) AS total_revenue
FROM session_dim s
JOIN transaction_fact t
    ON s.session_id = t.session_id
GROUP BY s.experiment_group;


EASY 2: Number of users by region

What we are trying to get:
User distribution across regions.

Concepts: GROUP BY, COUNT;

SELECT
    region,
    COUNT(DISTINCT user_id) AS total_users
FROM users_dim
GROUP BY region;

EASY 3: Average session time by device type

What we are trying to get:
Which device users spend more time on?

Concepts: GROUP BY, AVG;

SELECT
    device_type,
    ROUND(AVG(session_time_sec), 2) AS avg_session_time
FROM session_dim
GROUP BY device_type;

EASY 4: Total orders by payment method

What we are trying to get:
Which payment method is used most for completed transactions?

Concepts: GROUP BY, COUNT;

SELECT
    payment_method,
    COUNT(transaction_id) AS total_orders
FROM transaction_fact
GROUP BY payment_method;

EASY 5: Sessions count by experiment group

What we are trying to get:
How many sessions belong to each A/B group?

Concepts: GROUP BY;

SELECT
    experiment_group,
    COUNT(session_id) AS total_sessions
FROM session_dim
GROUP BY experiment_group;

-- MEDIUM LEVEL (5 QUESTIONS)

-- Focus: CTEs, conditional aggregation, joins

MEDIUM 1: Conversion rate by experiment group;
SELECT
    s.experiment_group,
    COUNT(CASE WHEN t.conversion = 1 THEN 1 END) * 1.0
        / COUNT(DISTINCT s.session_id) AS conversion_rate
FROM session_dim s
LEFT JOIN transaction_fact t
    ON s.session_id = t.session_id
GROUP BY s.experiment_group;

MEDIUM 2: Average revenue per user by region;
SELECT
    u.region,
    ROUND(SUM(t.revenue) / COUNT(DISTINCT u.user_id), 2) AS avg_revenue_per_user
FROM users_dim u
JOIN session_dim s
    ON u.user_id = s.user_id
JOIN transaction_fact t
    ON s.session_id = t.session_id
GROUP BY u.region;


MEDIUM 3: Sessions with above-average session time;
SELECT *
FROM session_dim
WHERE session_time_sec >
      (SELECT AVG(session_time_sec) FROM session_dim);

MEDIUM 4: Revenue by customer segment and experiment group;
SELECT
    u.customer_segment,
    s.experiment_group,
    ROUND(SUM(t.revenue), 2) AS total_revenue
FROM users_dim u
JOIN session_dim s
    ON u.user_id = s.user_id
JOIN transaction_fact t
    ON s.session_id = t.session_id
GROUP BY u.customer_segment, s.experiment_group;


MEDIUM 5: Top 5 users by total revenue;
SELECT
    u.user_id,
    ROUND(SUM(t.revenue), 2) AS total_revenue
FROM users_dim u
JOIN session_dim s
    ON u.user_id = s.user_id
JOIN transaction_fact t
    ON s.session_id = t.session_id
GROUP BY u.user_id
ORDER BY total_revenue DESC
LIMIT 5;


HARD LEVEL (5 QUESTIONS)

Focus: CTEs, window functions, advanced logic;

HARD 1: Rank regions by total revenue;
WITH region_revenue AS (
    SELECT
        u.region,
        SUM(t.revenue) AS total_revenue
    FROM users_dim u
    JOIN session_dim s ON u.user_id = s.user_id
    JOIN transaction_fact t ON s.session_id = t.session_id
    GROUP BY u.region
)
SELECT
    region,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM region_revenue;


HARD 2: Running total revenue by experiment group;
SELECT
    s.experiment_group,
    s.session_id,
    t.revenue,
    SUM(t.revenue) OVER (
        PARTITION BY s.experiment_group
        ORDER BY s.session_id
    ) AS running_revenue
FROM session_dim s
JOIN transaction_fact t
    ON s.session_id = t.session_id;


HARD 3: Top session per region by revenue;
WITH ranked_sessions AS (
    SELECT
        u.region,
        s.session_id,
        t.revenue,
        ROW_NUMBER() OVER (
            PARTITION BY u.region
            ORDER BY t.revenue DESC
        ) AS rn
    FROM users_dim u
    JOIN session_dim s ON u.user_id = s.user_id
    JOIN transaction_fact t ON s.session_id = t.session_id
)
SELECT
    region,
    session_id,
    revenue
FROM ranked_sessions
WHERE rn = 1;


HARD 4: Users who converted more than average;
SELECT
    u.user_id,
    COUNT(t.transaction_id) AS total_conversions
FROM users_dim u
JOIN session_dim s ON u.user_id = s.user_id
JOIN transaction_fact t ON s.session_id = t.session_id
WHERE t.conversion = 1
GROUP BY u.user_id
HAVING COUNT(t.transaction_id) >
       (
           SELECT AVG(conversion_count)
           FROM (
               SELECT COUNT(*) AS conversion_count
               FROM transaction_fact
               WHERE conversion = 1
               GROUP BY session_id
           ) sub
       );

HARD 5: Percentage contribution of each region to total revenue;
SELECT
    u.region,
    ROUND(SUM(t.revenue), 2) AS region_revenue,
    ROUND(
        SUM(t.revenue) * 100.0 /
        SUM(SUM(t.revenue)) OVER (),
        2
    ) AS revenue_percentage
FROM users_dim u
JOIN session_dim s ON u.user_id = s.user_id
JOIN transaction_fact t ON s.session_id = t.session_id
GROUP BY u.region;

FUNNEL ANALYSIS USING SQL;

Q1: How many total sessions do we have?
SELECT COUNT(*) AS total_sessions
FROM session_dim;

Q2: How many sessions viewed at least 1 item?
SELECT COUNT(*) AS viewed_sessions
FROM session_dim
WHERE num_items_viewed > 0;


Q3: How many sessions resulted in a transaction?
SELECT COUNT(DISTINCT session_id) AS transaction_sessions
FROM transaction_fact;

Q4: Funnel counts at each stage
SELECT
    COUNT(DISTINCT s.session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN s.num_items_viewed > 0 THEN s.session_id END) AS viewed_sessions,
    COUNT(DISTINCT t.session_id) AS transaction_sessions,
    COUNT(DISTINCT CASE WHEN t.conversion = 1 THEN t.session_id END) AS converted_sessions
FROM session_dim s
LEFT JOIN transaction_fact t
    ON s.session_id = t.session_id;

Q5: Funnel breakdown by experiment group (A vs B)
SELECT
    s.experiment_group,
    COUNT(DISTINCT s.session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN s.num_items_viewed > 0 THEN s.session_id END) AS viewed_sessions,
    COUNT(DISTINCT t.session_id) AS transaction_sessions,
    COUNT(DISTINCT CASE WHEN t.conversion = 1 THEN t.session_id END) AS converted_sessions
FROM session_dim s
LEFT JOIN transaction_fact t
    ON s.session_id = t.session_id
GROUP BY s.experiment_group;


Q6: Conversion rate at each funnel stage
WITH funnel AS (
    SELECT
        s.session_id,
        s.experiment_group,
        CASE WHEN s.num_items_viewed > 0 THEN 1 ELSE 0 END AS viewed,
        CASE WHEN t.session_id IS NOT NULL THEN 1 ELSE 0 END AS transacted,
        CASE WHEN t.conversion = 1 THEN 1 ELSE 0 END AS converted
    FROM session_dim s
    LEFT JOIN transaction_fact t
        ON s.session_id = t.session_id
)
SELECT
    experiment_group,
    COUNT(*) AS total_sessions,
    SUM(viewed) AS viewed_sessions,
    ROUND(SUM(viewed) / COUNT(*) * 100, 2) AS view_rate_pct,
    SUM(transacted) AS transaction_sessions,
    ROUND(SUM(transacted) / SUM(viewed) * 100, 2) AS transaction_rate_pct,
    SUM(converted) AS converted_sessions,
    ROUND(SUM(converted) / SUM(transacted) * 100, 2) AS conversion_rate_pct
FROM funnel
GROUP BY experiment_group;

Q7: Where is the biggest drop-off in the funnel?
WITH funnel AS (
    SELECT
        s.session_id,
        CASE WHEN s.num_items_viewed > 0 THEN 1 ELSE 0 END AS viewed,
        CASE WHEN t.session_id IS NOT NULL THEN 1 ELSE 0 END AS transacted,
        CASE WHEN t.conversion = 1 THEN 1 ELSE 0 END AS converted
    FROM session_dim s
    LEFT JOIN transaction_fact t
        ON s.session_id = t.session_id
)
SELECT
    'Session → View' AS stage,
    ROUND(100 - (SUM(viewed) / COUNT(*) * 100), 2) AS dropoff_pct
FROM funnel
UNION ALL
SELECT
    'View → Transaction',
    ROUND(100 - (SUM(transacted) / SUM(viewed) * 100), 2)
FROM funnel
UNION ALL
SELECT
    'Transaction → Conversion',
    ROUND(100 - (SUM(converted) / SUM(transacted) * 100), 2)
FROM funnel;


