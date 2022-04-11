-- development.ppc_conversion_pc_pv
WITH leads_click AS (
    SELECT source AS platform
         , campaign_name
         , residence
         , CAST(date_joined AS DATE) AS user_date_joined
         , binary_user_id
         , aff_status
         , 'post_click' AS conversion_type
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
     --     AND user_date.joined >= '2018-01-01'
            )
     WHERE channel = 'ppc'
)
, leads_view AS (
    SELECT platform
         , campaign_name
         , country AS residence
         , cast(date_joined AS DATE) AS user_date_joined
         , binary_user_id
         , aff_status
         , 'post_view' AS conversion_type
         , CAST(date_joined AS DATE) AS date
      FROM `business-intelligence-240201.ppc_model_post_view_conversion.ppc_lead_vw`
     WHERE conversion_type = 'post_view'
       AND (utm_medium NOT LIKE '%ppc%' OR utm_medium IS NULL)
)
, leads_all AS (
    SELECT *
      FROM leads_click

    UNION ALL

    SELECT *
      FROM leads_view
)
, leads AS (
    SELECT platform
         , campaign_name
         , residence
         , user_date_joined
         , binary_user_id
         , aff_status
         , conversion_type
         , date
         , 'user_lead_count' AS fact
         , 1 AS value
      FROM leads_all
)
, bo_vr AS(
    SELECT leads.* EXCEPT(date, fact, value)
         , CAST(creation_stamp AS DATE) AS date
         , 'bo_virtual' AS fact
         , 1 AS value
      FROM `business-intelligence-240201.bi.user_loginid`	AS uli
      JOIN  leads ON uli.binary_user_id = leads.binary_user_id
     WHERE uli.loginid LIKE 'VR%'
)
, bo_real AS(
    SELECT leads.* EXCEPT(date,fact,value)
         , CAST(creation_stamp AS DATE) AS date, 'bo_real' AS fact, 1 AS value
      FROM `business-intelligence-240201.bi.user_loginid` AS uli
      JOIN  leads ON uli.binary_user_id = leads.binary_user_id
     WHERE uli.loginid NOT LIKE 'VR%' AND uli.loginid NOT LIKE 'MT%')

, mt5_virtual AS (
    SELECT leads.* EXCEPT(date,fact,value)
         , CAST(creation_stamp AS DATE) AS date
         , 'mt5_demo' AS fact
         , 1 AS value
      FROM `business-intelligence-240201.bi.user_loginid` AS uli
      JOIN leads ON uli.binary_user_id = leads.binary_user_id
      WHERE uli.loginid LIKE 'MTD%'
)
, mt5_real AS (
    SELECT leads.* EXCEPT(date,fact,value)
         , cast(creation_stamp AS date) AS date
         , 'mt5_real' AS fact
         , 1 AS value
      FROM `business-intelligence-240201.bi.user_loginid` AS uli
      JOIN leads ON uli.binary_user_id = leads.binary_user_id
     WHERE uli.loginid LIKE 'MTR%'
)
,activated AS (
    SELECT leads.* EXCEPT(date,fact,value)
         , cast(first_deposit_time AS date) AS date
         , 'deposit_activated_bo_account' AS fact
         , 1 AS value
      FROM `business-intelligence-240201.bi.user_loginid` AS uli
      JOIN leads ON uli.binary_user_id = leads.binary_user_id
      LEFT JOIN `business-intelligence-240201.bi.bo_client` AS c ON uli.loginid = c.loginid
      WHERE first_deposit_time IS NOT NULL
)
,deposit AS (
    SELECT leads.* EXCEPT(date,fact,value)
         , cast(transaction_time AS date) AS date
         , 'client_deposit_usd' AS fact
         , round(sum(coalesce(amount_usd,0)),2) AS value
      FROM leads
      JOIN (SELECT transaction_time
                 , binary_user_id
                 , amount_usd
              FROM `business-intelligence-240201.bi.bo_payment_model`
             WHERE transaction_time >='2021-01-01'
               AND category IN ('Client Deposit','Payment Agent Deposit')
          ) AS pm
            ON leads.binary_user_id = pm.binary_user_id
     GROUP BY 1, 2, 3, 4, 5, 6, 7, 8,9
)
SELECT * FROM leads
UNION ALL
SELECT * FROM bo_vr
UNION ALL
SELECT * FROM bo_real
UNION ALL
SELECT * FROM mt5_virtual
UNION ALL
SELECT * FROM mt5_real
UNION ALL
SELECT * FROM activated
UNION ALL
SELECT * FROM deposit
