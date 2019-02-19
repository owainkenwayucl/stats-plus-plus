select SUM(cost*run_time) from %DB%.accounting_view inner join user_info.user_depts on %DB%.accounting_view.owner=user_info.user_depts.username where 
(end_time > start_time AND end_period = "%PERIOD%" AND user_info.user_depts.department = "%DEPARTMENT%");