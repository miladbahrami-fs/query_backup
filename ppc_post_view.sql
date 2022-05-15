CREATE OR REPLACE VIEW `business-intelligence-240201.ppc_model_post_view_conversion.ppc_lead_vw`
OPTIONS (
  description = " Post-view conversions of different PPC platforms, on daily basis"
) AS
SELECT * EXCEPT(rn)
  FROM (
      SELECT *
           , ROW_NUMBER() OVER (PARTITION BY binary_user_id ORDER BY platform,campaign_name) AS rn
        FROM (
          SELECT source AS platform
               , campaign_name
               , cast(adroll.user_id as int) as binary_user_id
               , conversion_type
               , residence AS country
               , users.user_date.joined AS date_joined
               , aff_status
               , users.acquisition.utm_medium
               , users.acquisition.utm_source
            FROM ppc_adroll.user_conversion as adroll
            JOIN bi.user_profile AS users
              ON cast(adroll.user_id as int) = users.binary_user_id
             AND date(users.user_date.joined) >= date(adroll.first_impression_time)

           UNION ALL

          SELECT source AS platform
               , campaign_name
               , cast(match2one.user_id as int) as binary_user_id
               , conversion_type
               , residence AS country
               , users.user_date.joined AS date_joined
               , aff_status
               , users.acquisition.utm_medium
               , users.acquisition.utm_source
            FROM ppc_match2one.user_conversion as match2one
            JOIN bi.user_profile AS users
              ON cast(match2one.user_id as int) = users.binary_user_id
             AND date(users.user_date.joined) >= date(match2one.first_impression_time)

           UNION ALL

          SELECT platform
               , campaign_name
               , binary_user_id
               , 'post_view' AS conversion_type
               , residence AS country
               , date_joined
               , aff_status
               , utm_medium
               , utm_source
            FROM (
                SELECT *
                      , CASE
                        WHEN conversion_type = 'post_click' THEN CAST(date_joined AS DATE) <= DATE_ADD(CAST(interaction_time AS DATE), INTERVAL 7 DAY)
                        WHEN conversion_type='post_view' THEN CAST(date_joined AS DATETIME) <= TIMESTAMP_ADD(interaction_time,INTERVAL 24 HOUR)
                        ELSE FALSE END AS is_in_window
                   FROM (
                      SELECT 'adform' AS platform
                           , campaign as campaign_name
                           , users.acquisition.utm_medium
                           , users.acquisition.utm_source
                           , users.acquisition.utm_campaign
                           , users.residence AS residence
                           , CAST(order_id AS integer) AS binary_user_id
                           , CASE
                              WHEN ad_interaction IN ('Impression','Recent Impression') THEN 'post_view'
                              ELSE 'post_click' END AS conversion_type
                           , DATETIME(date) AS interaction_time
                           , users.residence AS country
                           , users.user_date.joined AS date_joined
                           , aff_status
                        FROM development.adform_user_conversion AS adform
                        JOIN bi.user_profile AS users
                           ON CAST(adform.order_id AS int) = users.binary_user_id
                          AND DATE(users.user_date.joined) >= DATE(adform.date)
                          AND (users.acquisition.utm_medium NOT LIKE '%ppc%' OR users.acquisition.utm_medium IS NULL)
                          AND order_id<>'<userId>'
                    )
          )
           WHERE is_in_window

          UNION ALL

          SELECT 'growth' AS platform
                , REGEXP_EXTRACT(campaign,r'([^\s]+)' )AS campaign_name
                , order_id AS binary_user_id
                , 'post_view' AS conversion_type
                , user_profile.residence AS country
                , user_profile.user_date.joined AS date_joined
                , user_profile.aff_status
                , user_profile.acquisition.utm_medium
                , user_profile.acquisition.utm_source
             FROM development.growthchannel_post_view AS growth
             JOIN bi.user_profile ON user_profile.binary_user_id = growth.order_id
            WHERE growth.pv_pc_flag = 'View'

          UNION ALL

          SELECT 'yahoo' AS platform
               , campaign AS campaign_name
               , order_id AS binary_user_id
               , 'post_view' AS conversion_type
               , user_profile.residence AS country
               , user_profile.user_date.joined AS date_joined
               , user_profile.aff_status
               , user_profile.acquisition.utm_medium
               , user_profile.acquisition.utm_source
            FROM `business-intelligence-240201.development.yahoo_post_view` yahoo
            JOIN bi.user_profile ON user_profile.binary_user_id = yahoo.order_id
          )
     WHERE date_joined >= '2020-06-01') AS tmp
WHERE rn = 1
