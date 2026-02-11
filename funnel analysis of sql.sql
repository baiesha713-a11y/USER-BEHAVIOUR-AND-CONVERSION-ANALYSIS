USE ab_testing_db;

select *from transaction_fact;
select * from users_dim;
select * from session_dim;

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



