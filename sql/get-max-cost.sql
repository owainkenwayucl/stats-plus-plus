SELECT MAX(cost) AS max_cost FROM %DB%.accounting
    where (end_time > start_time 
    and end_period = "%PERIOD%");;