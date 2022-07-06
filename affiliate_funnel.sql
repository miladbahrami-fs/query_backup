-- development.affiliate_funnel
WITH ppc_leads AS (
  SELECT fact.binary_user_id
       , fact.platform
       , fact.campaign_name
       , fact.type
       , fact.conversion_type
       , active.is_active
    FROM (
          SELECT binary_user_id
               , source AS platform
               , campaign_name
               , 'ppc' AS type
               , 'post_click' AS conversion_type
            FROM ppc_model.ppc_lead_vw

          UNION ALL

          SELECT binary_user_id
               , platform
               , campaign_name
               , 'ppc' AS type
               , 'post_view' As conversion_type
            FROM ppc_model_post_view_conversion.ppc_lead_vw
           WHERE conversion_type = 'post_view'
             AND (utm_medium not like '%ppc%' or utm_medium is null) ) AS fact
    LEFT JOIN (
         SELECT DISTINCT platform
              , campaign
              , is_active
           FROM ppc_model.active_campaign
          WHERE campaign IS NOT NULL
            AND platform IS NOT NULL) AS active
      ON active.platform = fact.platform
     AND active.campaign = fact.campaign_name
)
SELECT up.binary_user_id
     , ppc_leads.platform
     , ppc_leads.campaign_name
     , ppc_leads.is_active AS campaign_is_active
     , COALESCE(ppc_leads.type,'non_ppc') AS type
     , ppc_leads.conversion_type
     , up.residence
     , up.aff_status
     , up.user_date.joined
     , up.user_date.joined_real
     , IF(up.user_date.joined_real IS NOT NULL,1,0) AS has_real
     , up.user_date.first_deposit
     , IF(up.user_date.first_deposit IS NOT NULL,1,0) AS is_funded
     , up.user_date.first_trade
     , IF(up.user_date.first_trade IS NOT NULL,1,0) AS has_trade
  FROM bi.user_profile up
  LEFT JOIN ppc_leads ON up.binary_user_id = ppc_leads.binary_user_id
