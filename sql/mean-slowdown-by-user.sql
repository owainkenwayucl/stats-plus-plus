SELECT end_period as period, 
       CONCAT_WS(' | ', t1.owner, fullname) AS owner, 
       AVG(slowdown) AS slowdown
       FROM %DB%.accounting_view AS t1 LEFT JOIN user_info.user_names AS t2 ON t1.owner = t2.username 
       WHERE (end_time > start_time AND end_period = "%PERIOD%") GROUP BY period,t1.owner;