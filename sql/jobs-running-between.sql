select job_number from %DB%.accounting where 
      ((end_time > unix_timestamp("%START%")) and 
      (end_time < unix_timestamp("%STOP%"))) or
      ((start_time > unix_timestamp("%START%")) and 
      (start_time < unix_timestamp("%STOP%"))) or
      ((start_time < unix_timestamp("%START%")) and
      (end_time > unix_timestamp("%STOP%")))