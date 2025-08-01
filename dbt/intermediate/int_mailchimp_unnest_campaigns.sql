with 

json as (

    select * from {{ ref('stg_mailchimp___campaigns') }}

)

select
  json_data:"_airbyte_data":"archive_url"::string AS archive_url,
  json_data:"_airbyte_data":"content_type"::string AS content_type,
  TRY_TO_TIMESTAMP(json_data:"_airbyte_data":"create_time"::string) AS create_time,
  json_data:"_airbyte_data":"emails_sent"::int AS emails_sent,
  json_data:"_airbyte_data":"id"::string AS id,
  json_data:"_airbyte_data":"long_archive_url"::string AS long_archive_url,
  json_data:"_airbyte_data":"needs_block_refresh"::boolean AS needs_block_refresh,
  json_data:"_airbyte_data":"resendable"::boolean AS resendable,
  TRY_TO_TIMESTAMP(json_data:"_airbyte_data":"send_time"::string) AS send_time,
  json_data:"_airbyte_data":"status"::string AS status,
  json_data:"_airbyte_data":"type"::string AS type,
  json_data:"_airbyte_data":"web_id"::int AS web_id,

  -- Nested: delivery_status
  json_data:"_airbyte_data":"delivery_status":"can_cancel"::boolean AS can_cancel,
  json_data:"_airbyte_data":"delivery_status":"emails_canceled"::int AS emails_canceled,
  json_data:"_airbyte_data":"delivery_status":"emails_sent"::int AS delivery_emails_sent,
  json_data:"_airbyte_data":"delivery_status":"enabled"::boolean AS delivery_enabled,
  json_data:"_airbyte_data":"delivery_status":"status"::string AS delivery_status,
 
  -- Nested: recipients
  json_data:"_airbyte_data":"recipients":"list_id"::string AS list_id,
  json_data:"_airbyte_data":"recipients":"list_is_active"::boolean AS list_is_active,
  json_data:"_airbyte_data":"recipients":"list_name"::string AS list_name,
  json_data:"_airbyte_data":"recipients":"recipient_count"::int AS recipient_count,

  -- Nested: report_summary
  json_data:"_airbyte_data":"report_summary":"click_rate"::float AS click_rate,
  json_data:"_airbyte_data":"report_summary":"clicks"::int AS clicks,
  json_data:"_airbyte_data":"report_summary":"open_rate"::float AS open_rate,
  json_data:"_airbyte_data":"report_summary":"opens"::int AS opens,
  json_data:"_airbyte_data":"report_summary":"subscriber_clicks"::int AS subscriber_clicks,
  json_data:"_airbyte_data":"report_summary":"unique_opens"::int AS unique_opens,

  -- Nested: report_summary.ecommerce
  json_data:"_airbyte_data":"report_summary":"ecommerce":"total_orders"::int AS ecommerce_orders,
  json_data:"_airbyte_data":"report_summary":"ecommerce":"total_revenue"::float AS ecommerce_revenue,
  json_data:"_airbyte_data":"report_summary":"ecommerce":"total_spent"::float AS ecommerce_spent,

  -- Nested: settings
  json_data:"_airbyte_data":"settings":"authenticate"::boolean AS authenticate,
  json_data:"_airbyte_data":"settings":"auto_footer"::boolean AS auto_footer,
  json_data:"_airbyte_data":"settings":"auto_tweet"::boolean AS auto_tweet,
  json_data:"_airbyte_data":"settings":"drag_and_drop"::boolean AS drag_and_drop,
  json_data:"_airbyte_data":"settings":"fb_comments"::boolean AS fb_comments,
  json_data:"_airbyte_data":"settings":"from_name"::string AS from_name,
  json_data:"_airbyte_data":"settings":"inline_css"::boolean AS inline_css,
  json_data:"_airbyte_data":"settings":"preview_text"::string AS preview_text,
  json_data:"_airbyte_data":"settings":"reply_to"::string AS reply_to,
  json_data:"_airbyte_data":"settings":"subject_line"::string AS subject_line,
  json_data:"_airbyte_data":"settings":"template_id"::int AS template_id,
  json_data:"_airbyte_data":"settings":"timewarp"::boolean AS timewarp,
  json_data:"_airbyte_data":"settings":"title"::string AS title,
  json_data:"_airbyte_data":"settings":"use_conversation"::boolean AS use_conversation,
  
  -- Nested: tracking
  json_data:"_airbyte_data":"tracking":"ecomm360"::boolean AS ecomm360,
  json_data:"_airbyte_data":"tracking":"goal_tracking"::boolean AS goal_tracking,
  json_data:"_airbyte_data":"tracking":"html_clicks"::boolean AS html_clicks,
  json_data:"_airbyte_data":"tracking":"opens"::boolean AS tracking_opens,
  json_data:"_airbyte_data":"tracking":"text_clicks"::boolean AS text_clicks,

 -- Meta fields
  TRY_TO_TIMESTAMP(json_data:"_airbyte_extracted_at"::string) AS extracted_at,
  json_data:"_airbyte_generation_id"::int AS generation_id,
  json_data:"_airbyte_raw_id"::string AS raw_id,
  json_data:"_airbyte_meta":sync_id::int AS sync_id

  from json
