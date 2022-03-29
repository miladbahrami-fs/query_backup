WITH
  fact AS (
  SELECT
    platform,
    campaign_name,
    DATE_TRUNC(date,WEEK(MONDAY)) AS week_date,
    SUM(e_impressions) AS impressions,
    SUM(e_clicks) AS clicks,
    SUM(e_spend) AS spends,
    round(safe_divide(SUM(e_spend),SUM(e_clicks)),4) as cpc,
    round(safe_divide(SUM(e_clicks),SUM(e_impressions)),4) as ctr,
    round(safe_divide(SUM(e_spend),SUM(e_user_lead_count)),4) as cpl,
    round(safe_divide(SUM(e_clicks),SUM(e_user_lead_count)),4) as click_per_lead,
    round(safe_divide(SUM(e_user_lead_count),SUM(e_clicks)),4) as click_to_lead,
    SUM(e_user_lead_count) AS leads,
    SUM(e_bo_virtual) AS bo_demo,
    SUM(e_bo_real) AS bo_real,
    SUM(e_mt5_demo) AS mt5_demo,
    SUM(e_client_deposit_usd) AS client_deposit_usd,
    SUM(e_mt5_real) AS mt5_real,
    SUM(e_deposit_activated_bo_account) AS bo_funded,
    ROUND(safe_divide(SUM(e_deposit_activated_bo_account),
          1.0*SUM(e_user_lead_count)),2) AS lead_to_funded,
    ROUND(safe_divide(SUM(e_bo_real),
          1.0*SUM(e_user_lead_count)),2) AS lead_to_bo_real,
    ROUND(safe_divide(SUM(e_mt5_real),
          1.0*SUM(e_user_lead_count)),2) AS lead_to_mt5_real
  FROM
    development.tmp_campaign_fact_pivot
  GROUP BY
    1,
    2,
    3)
SELECT
--   expense.* EXCEPT (campaign_name,
--     platform,
--     expense_week,
--     join_week),
--     user_count,click,spend),
  fact.*,
  round(safe_divide(spends,bo_real),2) as cpr,
  round(safe_divide(spends,bo_funded ),2) as cpa,
  CASE
    WHEN campaign IS NULL THEN FALSE
  ELSE
  TRUE
END
  AS active
FROM
  fact
-- JOIN
--   ppc_model.campaign_expense_model_scheduled expense
-- ON
--   expense.platform=fact.platform
--   AND expense.campaign_name=fact.campaign_name
--   AND expense.expense_week=fact.week_date
LEFT JOIN
  ppc_model.active_campaign active
ON
  active.platform=fact.platform
  AND active.campaign=fact.campaign_name