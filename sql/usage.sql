select sum((run_time*cost)) from %DB%.accounting_view where 
       ((end_time > start_time AND end_period = "%PERIOD%"));
