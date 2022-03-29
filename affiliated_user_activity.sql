WITH affiliate_lead AS (
  SELECT DISTINCT tmp.binary_user_id
       , LAST_VALUE(map.lead_id) OVER w AS lead_id
    FROM (
    SELECT DISTINCT us.binary_user_id
        , aff.aff_account AS affiliate_id
        , registration_ts AS date
      FROM bi.mt5_user AS us
      LEFT JOIN `business-intelligence-240201.partner_model.ib_main_tech_account_mapping_vw` AS map ON cast(us.agent AS STRING) = map.ib_login
      LEFT JOIN partner_model.affiliate AS aff ON map.ib_main = cast(aff.ib_account AS STRING)
     WHERE agent NOT IN (0) 
       AND DATE(registration_ts) < current_date
    UNION ALL 
    SELECT DISTINCT binary_user_id
         , affiliate_id
         , date_joined AS date
      FROM bi.bo_client
     WHERE affiliate_id NOT IN (0) 
       AND date(date_joined)< current_date
  )tmp
  LEFT JOIN close_io_marketing.lead_affiliate_mapping_vw as map  ON cast(tmp.affiliate_id as string) = map.affiliate_id
  WINDOW w AS (PARTITION BY binary_user_id ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
)
, client_deposit AS (
       SELECT DISTINCT bc.binary_user_id
            , map.lead_id
            , bc.affiliate_id
            , date(pm.transaction_time) AS transaction_date
            , sum(pm.amount_usd) AS client_deposit_usd
         FROM bi.bo_client AS bc
    LEFT JOIN `business-intelligence-240201.bi.bo_payment_model` as pm ON bc.binary_user_id = pm.binary_user_id
    LEFT JOIN close_io_marketing.lead_affiliate_mapping_vw as map ON cast(bc.affiliate_id as string) = map.affiliate_id
        WHERE bc.affiliate_id NOT IN (0)
--           AND pm.category IN ('Client Deposit') -- adding payment agent deposit to the categories
         AND pm.category IN ('Client Deposit' , 'Payment Agent Deposit')
         AND pm.transaction_time>= '2019-01-01'
         AND lead_id IS NOT NULL
     GROUP BY 1,2,3,4
)
, client_trade AS (
  SELECT date(trade_date) AS trade_date
       , al.lead_id
       , ts.binary_user_id
       , coalesce(sum(contract_count),0) AS total_trades
       , coalesce(sum(Case when app_type = 'Binary' THEN contract_count END),0) AS total_trades_binary
       , coalesce(sum(Case when app_type = 'Deriv' THEN contract_count END),0) AS total_trades_deriv
       , coalesce(sum(Case when app_type = 'MT5' THEN contract_count END),0) AS total_trades_mt5
       , coalesce(sum(Case when app_type = 'DerivX' THEN contract_count END),0) AS total_trades_derivx
       , coalesce(sum(Case when app_type = 'Other' THEN contract_count END),0) AS total_trades_other
  FROM (
    SELECT date as trade_date
         , binary_user_id
         , loginid
         , app_id
     , CASE WHEN platform ='DerivX' THEN 'DerivX'
            WHEN regexp_contains(platform, 'deriv') AND LOWER(platform) <> 'derivx' THEN 'Deriv'
            WHEN regexp_contains(platform, 'Deriv') AND LOWER(platform) <> 'derivx' THEN 'Deriv'
            WHEN regexp_contains(platform, 'binary') THEN 'Binary'
            WHEN regexp_contains(platform, 'Binary') THEN 'Binary'
            WHEN regexp_contains(platform, 'mt5') THEN 'MT5'
            WHEN regexp_contains(platform, 'MT5') THEN 'MT5'
            ELSE 'Others' END AS app_type
     , CASE WHEN regexp_contains(platform, 'deriv') AND LOWER(platform) <> 'derivx' THEN (number_of_trades/2)
            WHEN regexp_contains(platform, 'Deriv') AND LOWER(platform) <> 'derivx' THEN (number_of_trades/2)
            WHEN regexp_contains(platform, 'binary') THEN (number_of_trades/2)
            WHEN regexp_contains(platform, 'Binary') THEN (number_of_trades/2)
            ELSE number_of_trades END AS contract_count
      FROM `business-intelligence-240201.bi.trades` 
     WHERE date >= '2019-01-01'
   ) as ts 
    LEFT JOIN affiliate_lead AS al ON ts.binary_user_id = al.binary_user_id
   WHERE lead_id is not null
  GROUP BY 1 , 2 , 3
)
SELECT COALESCE(client_trade.binary_user_id , client_deposit.binary_user_id) AS binary_user_id
     , COALESCE(client_trade.trade_date , client_deposit.transaction_date) AS date
     , COALESCE(client_trade.lead_id , client_deposit.lead_id) AS lead_id
     , COALESCE(client_deposit_usd,0) AS client_deposit_usd
     , COALESCE(total_trades,0) AS total_trades
     , COALESCE(total_trades_binary,0) AS total_trades_binary
     , COALESCE(total_trades_deriv,0) AS total_trades_deriv
     , COALESCE(total_trades_mt5,0) AS total_trades_mt5
     , COALESCE(total_trades_derivx,0) AS total_trades_derivx
     , COALESCE(total_trades_other,0) AS total_trades_other
FROM client_deposit
FULL OUTER JOIN client_trade ON client_trade.binary_user_id = client_deposit.binary_user_id AND client_trade.trade_date = client_deposit.transaction_date
