-- campaign_fact_all_pivot_vw

with facts as(
SELECT * FROM
  (SELECT * FROM development.campaign_fact_all_scheduled)
  PIVOT(SUM(value) FOR fact IN ('clicks', 'deposit_activated_bo_account', 'view_bo_virtual', 'mt5_demo','impressions','view_mt5_real','view_user_deposit_usd','view_user_deposit_usd_non_aff','bo_real','view_user_deposit_usd_aff','view_bo_real','bo_virtual','view_user_deposit_activated','view_mt5_demo','mt5_real','user_lead_count','spend','client_deposit_usd','post_view_user_count'))
  )
select *, 
  CASE
    WHEN
      REGEXP_CONTAINS(campaign_name, ".*(fx-ebook).*") OR
      REGEXP_CONTAINS(campaign_name,".*(fx_ebook).*") OR
      REGEXP_CONTAINS(campaign_name,".*(fxebook).*") OR
      REGEXP_CONTAINS(campaign_name,".*(forexbook).*") OR
      REGEXP_CONTAINS(campaign_name,".*(forexebook).*") OR
      REGEXP_CONTAINS(campaign_name,".*(forex-book).*") OR
      REGEXP_CONTAINS(campaign_name,".*(forex_ebook).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(Spanish-forex_ebook).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(deriv-ebook).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(deriv_ebook).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(africa_tier2-lal-all-fx).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(latam-rtg_cpa-all-fx_ebo).*")
    THEN "forex_ebook"
    WHEN
      REGEXP_CONTAINS(campaign_name, ".*(crypto-ebook).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(crypto_ebook).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(cryptoebook).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(cryptobook).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(crypto-book).*")
    THEN 'crypto_ebook'
    WHEN
      REGEXP_CONTAINS(campaign_name, ".*(stock-ebook).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(stock_ebook).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(stockebook).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(stocks-ebook).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(stocks_ebook).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(stocksebook).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(africa-rtg-all-stock_ebo).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(africa_tier2-rtg-all-sto).*") 
      THEN 'stocks_ebook'
    WHEN
      REGEXP_CONTAINS(campaign_name, ".*(search-stock).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(Deriv-stock).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(deriv-stocks).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(deriv_stock).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(deriv-stock).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(deriv_stocks).*")
    THEN 'stocks_cfd'
    WHEN
      REGEXP_CONTAINS(campaign_name, ".*(brand_video).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(brandvideo).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(brand_awareness).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(tz-prosp_cpm-all-brand_).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(gh-prosp_cpm-all-brand_a).*") 
    THEN 'brand_awareness'
    WHEN 
      REGEXP_CONTAINS(campaign_name, ".*(weekend-trading).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(weekend_trading).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(weekendtrading).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(africa_tier1-lal-all-wee).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(africa_tier2-lal-all-wee).*")
    THEN 'weekend_trading'
    WHEN 
      REGEXP_CONTAINS(campaign_name, ".*(deriv-trends).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(africa-trends).*") 
    THEN 'crypto'
    WHEN 
      REGEXP_CONTAINS(campaign_name, ".*(allproducts).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(Web Retargeting).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(deriv remarketing).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(retargeting campaign).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(all-retargeting).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(deriv_cfd).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(deriv-cfd).*") 
    THEN 'all_products'
    WHEN 
      REGEXP_CONTAINS(campaign_name, ".*(dtrader).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(deriv-dtrader).*") 
    THEN 'dtrader'
    WHEN 
      REGEXP_CONTAINS(campaign_name, ".*(mob-deriv_go).*") 
    THEN 'deriv_go'
    WHEN
      REGEXP_CONTAINS(campaign_name, ".*(skrill).*")
    THEN 'skrill_signups'
    WHEN
      REGEXP_CONTAINS(campaign_name, ".*(deriv-multiplier).*")
    THEN 'multipliers'
    WHEN
      REGEXP_CONTAINS(campaign_name, ".*(search-english).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(search-en).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(vietnam-search-vietnamese).*")
    THEN 'search_all_products'
    WHEN
      REGEXP_CONTAINS(campaign_name, ".*(deriv-dmt5).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(deriv-mt5).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(deriv_dmt5).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(dmt5).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(deriv_all).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(deriv-all).*") 
    THEN 'deriv_mt5'
    WHEN
      REGEXP_CONTAINS(campaign_name, ".*(swanglish).*") 
    THEN 'swahili_english'
    WHEN
      REGEXP_CONTAINS(campaign_name, ".*(deriv-synthetic).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(deriv-syntheticindex).*") 
    THEN 'synthetic_indices'
    WHEN 
      REGEXP_CONTAINS(campaign_name, ".*(cta_button).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(ctabutton).*")
    THEN 'investingdotcom_cta'
    WHEN
      REGEXP_CONTAINS(campaign_name, ".*(fx_spreads).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(fx-spreads).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(fxspreads).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(forex-spreads).*") OR 
      REGEXP_CONTAINS(campaign_name, ".*(forexspreads).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(ng-prosp-cpc-all-fx_spr).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(ng-lal-cpc-all-fx_spread).*") OR
      REGEXP_CONTAINS(campaign_name, ".*(za-prosp-cpc-all-fx_spre).*")
    THEN 'forex_spreads'
  ELSE 'Other' END AS campaign_theme
from facts