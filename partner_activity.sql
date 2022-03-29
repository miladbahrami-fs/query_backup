WITH
  activities AS (
  SELECT
    affiliate_id AS partner_id,
    DATE_TRUNC(transaction_date, month) AS transaction_month,
    metric,
    SUM(value) value
  FROM
    partner_model.fact_metric_client_payment_bo fb
  JOIN
    bi.bo_client bc ON bc.loginid=fb.client_loginid
  WHERE
    bc.affiliate_id<>0
    AND metric='client_deposit_usd'
  GROUP BY
    1,
    2,
    3
  UNION ALL
  SELECT
    affiliate_id AS partner_id,
    DATE_TRUNC(transaction_date,month) AS transaction_month,
    metric,
    SUM(value) value
  FROM
    partner_model.fact_metric_client_signup_bo fs
  JOIN
    bi.bo_client bc
  ON
    bc.loginid=fs.client_loginid
  WHERE
    bc.affiliate_id<>0
    AND metric='client_signup'
  GROUP BY
    1,
    2,
    3),
  aff_time AS (
  SELECT
    DATE(first_day_of_month) AS date,
    aff.affiliate_id,
  FROM
    bi.dimension_calendar cal
  JOIN
    development.affiliate_profile aff
  ON
    TRUE
  WHERE
    date_actual >='2020-01-01'
    AND date_actual < current_date
    AND date_actual >= DATE(date_joined)
  GROUP BY
    1,
    2 ),
  aff_model AS(
  SELECT
    aff.*,
    date AS transaction_month,
    metric,
    value
  FROM
    aff_time
  LEFT JOIN
    `business-intelligence-240201.development.affiliate_profile` aff
  ON
    aff.affiliate_id=aff_time.affiliate_id
  LEFT JOIN
    activities
  ON aff_time.affiliate_id=activities.partner_id
    AND DATE(aff_time.date)=DATE(activities.transaction_month) ),
final as (SELECT
  *
FROM (
  SELECT
    *
  FROM
    aff_model) PIVOT(SUM(value) FOR metric IN ('client_deposit_usd',
      'client_signup'))
ORDER BY
  affiliate_id,
  transaction_month)
  select final.*,
  dc.internal_regional_group as marketing_region,
  dc.assingments as country_manager
  from final 
  left join `business-intelligence-240201.dictionary.country_region_external` dc
  on dc.country=final.country