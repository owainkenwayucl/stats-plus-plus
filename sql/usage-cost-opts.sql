select sum((run_time*cost))/3600 from %DB%.accounting_view where 
       ((end_time > start_time AND end_period = "%PERIOD%")
        AND (cost >= %LOWERCOST% AND cost <= %UPPERCOST%)       
        %ONLIMITS% );
