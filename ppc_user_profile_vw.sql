WITH post_click AS (
SELECT *
  FROM `business-intelligence-240201.ppc_model.ppc_lead_vw`
 WHERE channel = 'ppc'
)
,post_view AS (
SELECT binary_user_id
     , platform
     , campaign_name
     , cast(date_joined AS DATE) AS date_joined
     , aff_status
     , country
  FROM ppc_model_post_view_conversion.ppc_lead_vw
 WHERE conversion_type = 'post_view' AND (utm_medium NOT LIKE '%ppc%' OR utm_medium IS NULL))
,all_conversions AS (
SELECT binary_user_id
     , source AS platform
     , campaign_name
     , DATE(date_joined) AS date_joined
     , country AS residence
     , 'post_click' AS conversion_type 
  FROM post_click
 UNION ALL
SELECT binary_user_id
     , platform
     , campaign_name
     , date_joined
     , country AS residence
     , 'post_view' AS conversion_type 
  FROM post_view)
SELECT all_conversions.*
     , up.lifetime_payment.deposit_usd 
  FROM all_conversions
  LEFT JOIN bi.user_profile up ON up.binary_user_id = all_conversions.binary_user_id