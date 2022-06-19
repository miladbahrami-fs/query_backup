-- with tmp as (SELECT
--     'adform' AS platform,
--     campaign_name,
--     users.acquisition.utm_medium,
--     users.acquisition.utm_source,
--     users.acquisition.utm_campaign,
--     users.residence as residence,
--     cast(order_id as integer) AS binary_user_id,
--     case when ad_interaction in ('Impression','Recent Impression') then 'post_view' else 'post_click' end as conversion_type,
--     timestamp as interaction_time,
--     country,
--     users.user_date.joined AS date_joined,
--     aff_status
--     FROM
--     development.adform_user_conversion_table AS adform
--     JOIN
--     bi.user_profile AS users
--     ON
--     CAST(adform.order_id AS int) = users.binary_user_id
--     AND DATE(users.user_date.joined) >= DATE(adform.timestamp)
--     and (users.acquisition.utm_medium not like '%ppc%' or users.acquisition.utm_medium is null)
--     and order_id<>'<userId>')
-- select *,
-- case when conversion_type='post_click' then cast(date_joined as date) <= date_add(cast(interaction_time as date), INTERVAL 7 DAY)
-- when conversion_type='post_view' then date_joined <= timestamp_add(interaction_time,INTERVAL 24 HOUR)
-- else false end as is_in_window
-- from tmp
CREATE OR REPLACE VIEW
SELECT *
     , CASE
        WHEN conversion_type = 'post_click' THEN cast(date_joined as date) <= date_add(cast(interaction_time as date), INTERVAL 7 DAY)
        WHEN conversion_type = 'post_view' THEN cast(date_joined as DATETIME) <= timestamp_add(interaction_time,INTERVAL 24 HOUR)
        ELSE false END AS is_in_window
  FROM (
        SELECT 'adform' AS platform
             , campaign as campaign_name
             , users.acquisition.utm_medium
             , users.acquisition.utm_source
             , users.acquisition.utm_campaign
             , users.residence as residence
             , cast(order_id as integer) AS binary_user_id
             , CASE
                WHEN ad_interaction IN ('Impression','Recent Impression')
                THEN 'post_view'
                ELSE 'post_click' END AS conversion_type
             , datetime(date) as interaction_time
             , country
             , users.user_date.joined AS date_joined
             , aff_status
          FROM development.adform_user_conversion AS adform
          JOIN bi.user_profile AS users ON CAST(adform.order_id AS INT) = users.binary_user_id
           AND DATE(users.user_date.joined) >= DATE(adform.date)
           AND (users.acquisition.utm_medium NOT LIKE '%ppc%' OR users.acquisition.utm_medium IS NULL)
           AND order_id<>'<userId>'
      )
