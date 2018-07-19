SELECT MAX(cost) AS max_cost FROM %DB%.accounting_view
    where (end_time > start_time 
    and end_period = "%PERIOD%");