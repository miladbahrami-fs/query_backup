WITH master AS(
  SELECT
    parent_user_id AS affiliate_id,
    true as is_master_affiliate
  FROM 
    `business-intelligence-240201.partner_model.affiliate`
  where 
    parent_user_id is not null
  GROUP BY 1
)
,sub AS(
  SELECT
    aff_account AS affiliate_id,
    true AS is_sub_affiliate
  FROM 
    `business-intelligence-240201.partner_model.affiliate`
  WHERE
    parent_user_id is not null
  GROUP BY 1
)
,commissions AS(
  SELECT
    affiliate_id,
    SUM(COALESCE(affiliate_commission_usd,0)) AS affiliate_commission_usd,
    SUM(COALESCE(ib_commission_usd,0)) AS ib_commission_usd
  FROM 
    myaffiliate_reconciliation.affiliate_ib_commission_vw
  GROUP BY 1
)
SELECT
  affiliate.aff_account AS affiliate_id,
  affiliate.email,
  affiliate.date_joined,
  dict_country.country,
  affiliate.first_activity_date,
  affiliate.last_activity_date,
  affiliate.status,
  affiliate.binary_user_id,
  affiliate.is_client,
  COALESCE(master.is_master_affiliate, false) AS is_master_affiliate,
  COALESCE(sub.is_sub_affiliate, false) AS is_sub_affiliate,
  CASE WHEN affiliate.ib_account is null then false else true end as is_ib,
  affiliate.ib_account,
  COALESCE(bc.count_user_signups,0) AS count_options_user_signups,
  COALESCE(mt5.count_mt5_user_signups,0) AS count_mt5_user_signups,
  commissions.affiliate_commission_usd AS total_affiliate_commission_usd,
  commissions.ib_commission_usd AS total_ib_commission_usd
FROM 
  `business-intelligence-240201.partner_model.affiliate` AS affiliate
LEFT JOIN 
  bi.dict_country
  ON 
    dict_country.iso2_small = affiliate.country
LEFT JOIN 
  master
  ON
    master.affiliate_id = affiliate.aff_account
LEFT JOIN 
  sub
  ON 
    sub.affiliate_id = affiliate.aff_account
LEFT JOIN (
  SELECT 
    affiliate_id,
    count(distinct binary_user_id) count_user_signups
  FROM bi.bo_client
  GROUP BY 1
  )bc
  ON
    bc.affiliate_id = affiliate.aff_account
LEFT JOIN (
  SELECT 
    agent AS ib_account,
    count(distinct binary_user_id) count_mt5_user_signups
  FROM bi.mt5_user
  GROUP BY 1
  )mt5
  ON
    mt5.ib_account = affiliate.ib_account
LEFT JOIN 
  commissions
    ON commissions.affiliate_id = affiliate.aff_account
ORDER BY 10 DESC