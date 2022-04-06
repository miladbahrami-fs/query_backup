WITH leads_click AS (
    SELECT source AS platform
         , campaign_name
         , residence
         , CAST(date_joined AS DATE) AS user_date_joined
         , binary_user_id
         , aff_status
         , CAST(date_joined AS DATE) AS date
      FROM (
       SELECT binary_user_id
            , aff_status
            , acquisition.utm_medium
            , acquisition.utm_source
            , acquisition.utm_campaign
            , acquisition.channel
            , acquisition.subchannel
            , acquisition.source
            , acquisition.placement
            , acquisition.campaign_name
            , residence
            , user_date.joined as date_joined
        FROM bi.user_profile
       WHERE acquisition.channel = 'ppc'
         AND user_date.joined >= '2020-06-01'
            )
     WHERE channel = 'ppc'
)
, leads_view AS (
    SELECT platform
         , campaign_name
         , country AS residence
         , cast(date_joined AS DATE) AS user_date_joined
         , binary_user_id,aff_status
         , CAST(date_joined AS DATE) AS date
      FROM `business-intelligence-240201.ppc_model_post_view_conversion.ppc_lead_vw`
     WHERE conversion_type = 'post_view'
       AND (utm_medium NOT LIKE '%ppc%' OR utm_medium IS NULL)
)
SELECT *
  FROM leads_click
UNION ALL
SELECT *
  FROM leads_view
