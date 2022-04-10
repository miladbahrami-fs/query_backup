SELECT bpm.binary_user_id
     , DATE(transaction_time) transaction_date
     , platform
     , campaign_name
     , date_joined
     , residence
     , aff_status
     , conversion_type
     , SUM(amount_usd) as amount_usd
  FROM bi.bo_payment_model bpm
  JOIN development.ppc_user_profile_vw up ON bpm.binary_user_id = up.binary_user_id
 WHERE transaction_time >= '2022-01-01' AND category IN ('Client Deposit','Payement Agent Deposit')
 GROUP BY 1,2,3,4,5,6,7,8
