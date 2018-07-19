select sum(cost * run_time) as cpu_time from %DB%.accounting_view 
    where (cost > %MINCOST% 
    and cost <= %MAXCOST% 
    and end_time > start_time 
    and end_period = "%PERIOD%");