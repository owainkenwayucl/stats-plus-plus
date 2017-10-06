# Heather wrote this and I converted it to use SimpleTemplate.

SELECT COUNT(*) as num_jobs, sum(cost*ru_wallclock)/3600 AS core_hours, 
       sum(cost*ru_wallclock)/(3600*17000) AS machine_hours

FROM %DB%.accounting AS t1 
# inner join to get only the jobs that have these users
INNER JOIN (
    # Get distinct users only and concatenate all their projects into one
    # because we still need a project field
    SELECT username, GROUP_CONCAT(project SEPARATOR ', ') AS proj
    FROM thomas.projectusers 
    WHERE thomas.projectusers.project LIKE '%PROJECT%%'
    GROUP BY username
    
    ) AS distinctuser
    
    ON t1.owner = distinctuser.username 

WHERE
    end_time > start_time
    AND date_format(from_unixtime(end_time),"%Y-%m") = '%PERIOD%'

    AND (
        t1.project='Gold' AND SUBSTRING_INDEX(account, ';', 1) LIKE '%PROJECT%%' # paid jobs for this project only
        OR t1.project='AllUsers' # any free jobs from this user
    )

