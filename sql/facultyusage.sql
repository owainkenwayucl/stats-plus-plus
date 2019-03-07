SELECT
    t1.end_period              AS `Period`,
    SUM(t1.cost * t1.run_time) AS `Total CPU Time Usage`
FROM %DB%.accounting_view AS t1 LEFT JOIN user_info.user_depts AS t2 ON t1.owner = t2.username
    WHERE t1.end_time > t1.start_time AND
    t2.department IN %DEPARTMENT%
    GROUP BY `Period`;