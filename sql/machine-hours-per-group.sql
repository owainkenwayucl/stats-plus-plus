# Heather wrote this - need to convert to use Simpletemplate.

SELECT COUNT(*) as num_jobs, sum(cost*ru_wallclock)/3600 AS core_hours, 
  sum(cost*ru_wallclock)/(3600*17000) AS machine_hours, t1.owner 

FROM thomas_sgelogs.accounting AS t1 
# inner join to get only the jobs that have these users
  INNER JOIN (
    # Get distinct users only and concatenate all their projects into one
	# because we still need a project field
    SELECT username, GROUP_CONCAT(project SEPARATOR ', ') AS proj 
    FROM thomas.projectusers 
    WHERE thomas.projectusers.project LIKE 'UKCP%'
    GROUP BY username
  ) AS distinctuser

  ON t1.owner = distinctuser.username 

WHERE  
  end_time > start_time 
  AND start_time > unix_timestamp('2017-09-01 00:00:01') #Sept
  AND end_time < unix_timestamp('2017-10-01 00:00:00')   #Sept
#  AND start_time > unix_timestamp('2017-06-01 00:00:01') #June
#  AND end_time < unix_timestamp('2017-09-01 00:00:00')   #Aug
  AND (
    t1.project='Gold' AND SUBSTRING_INDEX(account, ';', 1) LIKE 'UKCP%' # paid jobs for this project only
    OR t1.project='AllUsers' # any free jobs from this user
  )

