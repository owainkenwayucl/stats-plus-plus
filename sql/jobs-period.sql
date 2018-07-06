select job_number from %DB%.accounting where 
	(end_time > start_time AND end_period = "%PERIOD%");
