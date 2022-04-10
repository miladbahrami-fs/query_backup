SELECT fact.*
     , is_active
  FROM development.campaign_fact_all_pivot_vw fact
  LEFT JOIN (
        SELECT DISTINCT platform
             , campaign, is_active
          FROM ppc_model.active_campaign
         WHERE campaign IS NOT NULL AND platform IS NOT NULL
       ) AS ac ON ac.platform=fact.platform AND ac.campaign=fact.campaign_name
 WHERE DATE < DATE_SUB(current_date, INTERVAL 1 DAY)
