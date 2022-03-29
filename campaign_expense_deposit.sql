-- development.campaign_expense_deposit

SELECT expen.*
     , user_deposit.* except (binary_user_id)
     , user_profile.aff_status
  FROM ppc_model_post_view_conversion.ppc_lead_with_expense_include_view_scheduled expen
  JOIN ppc_model.user_deposit ON user_deposit.binary_user_id=expen.binary_user_id
  JOIN bi.user_profile ON user_profile.binary_user_id=expen.binary_user_id