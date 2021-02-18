SELECT
    t1.end_period			AS `Period`,
    SUM((t1.cost * t1.run_time)/3600)	AS `Total CPU Time Usage`,
    ref_cat_table.ref_category		AS ref_category
FROM %DB%.accounting_view		AS t1
RIGHT JOIN user_info.user_refcats 	AS ref_cat_table 
    ON t1.owner = ref_cat_table.username 
    WHERE end_time > start_time
    AND ref_cat_table.ref_category IN %REFCAT%
    GROUP BY end_period, ref_cat_table.ref_category;
