

1)....Sample size check (A vs B)
SELECT 
    experiment_group,
    COUNT(DISTINCT user_id) AS users,
    COUNT(DISTINCT session_id) AS sessions
FROM session_dim
GROUP BY experiment_group;

2)....Conversion rate by group
SELECT 
    s.experiment_group,
    COUNT(DISTINCT t.transaction_id) / COUNT(DISTINCT s.session_id) AS conversion_rate
FROM session_dim s
LEFT JOIN transaction_fact t
    ON s.session_id = t.session_id
GROUP BY s.experiment_group;


3)....Avg revenue per user (ARPU)
SELECT
    s.experiment_group,
    SUM(t.revenue) / COUNT(DISTINCT s.user_id) AS arpu
FROM session_dim s
LEFT JOIN transaction_fact t
    ON s.session_id = t.session_id
GROUP BY s.experiment_group;


4)....Device-wise A/B performance
SELECT
    s.device_type,
    s.experiment_group,
    COUNT(t.transaction_id) / COUNT(DISTINCT s.session_id) AS conversion_rate
FROM session_dim s
LEFT JOIN transaction_fact t
    ON s.session_id = t.session_id
GROUP BY s.device_type, s.experiment_group;


5)....Traffic source impact
SELECT
    s.traffic_source,
    s.experiment_group,
    SUM(t.revenue) AS total_revenue
FROM session_dim s
LEFT JOIN transaction_fact t
    ON s.session_id = t.session_id
GROUP BY s.traffic_source, s.experiment_group;
