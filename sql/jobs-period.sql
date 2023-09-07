select t1.job_number,from_unixtime(min(submission_time)) as submit_time,from_unixtime(max(start_time)) as start_time, from_unixtime(t2.max_end_time) as end_time, cost from %DB%.accounting as t1 
	join (select job_number,max(end_time) as max_end_time from %DB%.accounting
             group by job_number) as t2 
        on t1.job_number = t2.job_number
	where  (date_format(from_unixtime(max_end_time),'%Y-%m') = "%PERIOD%")

