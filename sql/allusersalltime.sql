SELECT COUNT(DISTINCT(an_owner)) AS `Total Users`,
       `Period`
FROM (
        (SELECT DISTINCT `owner` AS `an_owner`,
                         DATE_FORMAT(FROM_UNIXTIME(end_time), "%Y-%m") AS `Period`
         FROM sgelogs2.accounting
         WHERE end_time != 0)
      UNION ALL
        (SELECT DISTINCT `owner` AS `an_owner`,
                         DATE_FORMAT(FROM_UNIXTIME(end_time), "%Y-%m") AS `Period`
         FROM sgelogs.accounting
         WHERE end_time != 0)
      UNION ALL
        (SELECT DISTINCT `owner` AS `an_owner`,
                         DATE_FORMAT(FROM_UNIXTIME(end_time), "%Y-%m") AS `Period`
         FROM grace_sgelogs.accounting
         WHERE end_time != 0)
      UNION ALL
        (SELECT DISTINCT `owner` AS `an_owner`,
                         DATE_FORMAT(FROM_UNIXTIME(end_time), "%Y-%m") AS `Period`
         FROM thomas_sgelogs.accounting
         WHERE end_time != 0)
      UNION ALL
        (SELECT DISTINCT `owner` AS `an_owner`,
                         DATE_FORMAT(FROM_UNIXTIME(end_time), "%Y-%m") AS `Period`
         FROM michael_sgelogs.accounting
         WHERE end_time != 0)
      UNION ALL
        (SELECT DISTINCT `owner` AS `an_owner`,
                         DATE_FORMAT(FROM_UNIXTIME(end_time), "%Y-%m") AS `Period`
         FROM myriad_sgelogs.accounting
         WHERE end_time != 0)) AS t
GROUP BY `Period`;

