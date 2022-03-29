SELECT 'adform' AS platform
     , date
     , campaign_name
     , NULL AS campaign_id
     , line_item AS country
     , cost as spend
     ,tracked_ads as impressions
     , NULL AS reach
     , NULL AS frequency
     , clicks
     , NULL AS cpm
     , NULL AS cpc
FROM `business-intelligence-240201.development.adform_performance_table`
UNION ALL
SELECT 'adform' AS platform
     , date
     , campaign_name
     , NULL AS campaign_id
     , country
     , spend as spend
     , impressions as impressions
     , NULL AS reach
     , NULL AS frequency
     , clicks
     , NULL AS cpm
     , NULL AS cpc
FROM `business-intelligence-240201.development.adform_performance_table_1221`