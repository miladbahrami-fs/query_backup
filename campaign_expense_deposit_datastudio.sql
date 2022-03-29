-- query for campaign expense depoist data source in data studio
select expense.*,is_active from `business-intelligence-240201.development.campaign_expense_deposit` expense
left join ppc_model.active_campaign ac on ac.platform=expense.platform and ac.campaign=expense.campaign_name