SELECT
    t1.end_period                     AS `Period`,
    t2.department                     AS `Department`,
    SUM((t1.cost * t1.run_time)/360)0 AS `Total CPU Time Usage`
FROM %DB%.accounting_view AS t1 LEFT JOIN user_info.user_depts AS t2 ON t1.owner = t2.username
    WHERE t1.end_time > t1.start_time
    GROUP BY `Period`, `Department`;