select owner,sum(run_time*cost) as cpu_time from %DB%.accounting_view where 
      ((end_time > unix_timestamp("%START%")) and 
      (end_time < unix_timestamp("%STOP%"))) or
      ((start_time > unix_timestamp("%START%")) and 
      (start_time < unix_timestamp("%STOP%"))) or
      ((start_time < unix_timestamp("%START%")) and
      (end_time > unix_timestamp("%STOP%"))) group by owner;