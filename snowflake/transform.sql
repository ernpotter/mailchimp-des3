USE DATABASE <your_database>;
USE SCHEMA <your_schema>;

---- Previewing Raw Campaigns Table -----
SELECT *
FROM mailchimp_campaigns_raw_airbyte;

DESC TABLE mailchimp_campaigns_raw_airbyte; // confirming column name 


--- Unnesting Campaigns into one flat wide table  ----
CREATE OR REPLACE TABLE mailchimp_campaigns_unnest1 AS 
SELECT
  -- Top-level fields
  json_data:"_airbyte_data":"archive_url"::string AS archive_url,
  json_data:"_airbyte_data":"content_type"::string AS content_type,
  json_data:"_airbyte_data":"create_time"::datetime AS create_time,
  json_data:"_airbyte_data":"emails_sent"::int AS emails_sent,
  json_data:"_airbyte_data":"id"::string AS id,
  json_data:"_airbyte_data":"long_archive_url"::string AS long_archive_url,
  json_data:"_airbyte_data":"needs_block_refresh"::boolean AS needs_block_refresh,
  json_data:"_airbyte_data":"resendable"::boolean AS resendable,
  json_data:"_airbyte_data":"send_time"::timestamp AS send_time,
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
  json_data:"_airbyte_extracted_at"::timestamp AS extracted_at,
  json_data:"_airbyte_generation_id"::int AS generation_id,
  json_data:"_airbyte_raw_id"::string AS raw_id,
  json_data:"_airbyte_meta":sync_id::int AS sync_id

FROM mailchimp_campaigns_raw_airbyte;

--- previewing unnested campaigns tables---
SELECT *
FROM mailchimp_campaigns_unnest1;


---- Previewing Raw Email Activity Table -----
SELECT *
FROM mailchimp_email_activity_raw_airbyte;

--- Unnesting Email Activty into one flat wide table  ----
CREATE OR REPLACE TABLE mailchimp_email_activity_unnest1 AS 
SELECT
  -- Top-level fields from _airbyte_data
  json_data:"_airbyte_data":"action"::STRING AS action,
  json_data:"_airbyte_data":"campaign_id"::STRING AS campaign_id,
  json_data:"_airbyte_data":"email_address"::STRING AS email_address,
  json_data:"_airbyte_data":"email_id"::STRING AS email_id,
  json_data:"_airbyte_data":"ip"::STRING AS ip,
  json_data:"_airbyte_data":"list_id"::STRING AS list_id,
  json_data:"_airbyte_data":"list_is_active"::BOOLEAN AS list_is_active,
  json_data:"_airbyte_data":"timestamp"::TIMESTAMP_TZ AS action_timestamp,

  -- Metadata fields
  TO_TIMESTAMP_LTZ(json_data:"_airbyte_extracted_at"::NUMBER / 1000) AS extracted_at,
  json_data:"_airbyte_generation_id"::INT AS generation_id,
  json_data:"_airbyte_raw_id"::STRING AS raw_id,
  json_data:"_airbyte_meta":sync_id::INT AS sync_id

FROM mailchimp_email_activity_raw_airbyte;

--- Previewing unnested email_activity table---
SELECT *
FROM mailchimp_email_activity_unnest1
;


SELECT *
FROM mailchimp_campaigns_unnest1;

SELECT COUNT(DISTINCT archive_url)
FROM mailchimp_campaigns_unnest1;



------ Creating Silver Layer Tables -----


---- mailchimp_dim_campaign_silver-------
CREATE OR REPLACE TABLE mailchimp_dim_campaign_silver AS
SELECT 
    id as campaign_id,
    archive_url,
    long_archive_url,
    content_type,
    create_time,
    send_time,
    status,
    type,
    web_id,
    resendable,
    needs_block_refresh,
    template_id,
    list_id,
FROM mailchimp_campaigns_unnest1;

SELECT *
FROM mailchimp_dim_campaign_silver;


---- mailchimp_dim_delivery_status_silver-------
CREATE OR REPLACE TABLE mailchimp_dim_delivery_status_silver AS
SELECT 
    id as campaign_id,
    can_cancel,
    emails_canceled,
    emails_sent,
    delivery_enabled,
    status,
FROM mailchimp_campaigns_unnest1;

SELECT *
FROM mailchimp_dim_delivery_status_silver;


---- mailchimp_dim_tracking_silver-------
CREATE OR REPLACE TABLE mailchimp_dim_tracking_silver AS
SELECT 
    id as campaign_id,
    ecomm360,
    goal_tracking,
    html_clicks,
    opens,
    text_clicks
FROM mailchimp_campaigns_unnest1;

SELECT *
FROM mailchimp_dim_tracking_silver;


---- mailchimp_fact_campaign_report_summary_silver-------
CREATE OR REPLACE TABLE mailchimp_fact_campaign_report_summary_silver AS
SELECT 
    id as campaign_id,
    click_rate,
    clicks,
    open_rate,
    opens,
    subscriber_clicks,
    unique_opens,
    ecommerce_orders,
    ecommerce_revenue,
    ecommerce_spent
FROM mailchimp_campaigns_unnest1;

SELECT *
FROM mailchimp_fact_campaign_report_summary_silver;


---- mailchimp_dim_list_silver-------
CREATE OR REPLACE TABLE mailchimp_dim_list_silver AS
SELECT 
    list_id,
    list_name,
    list_is_active,
    recipient_count
FROM mailchimp_campaigns_unnest1;

SELECT *
FROM mailchimp_dim_list_silver;

---- mailchimp_dim_template_silver-------
CREATE OR REPLACE TABLE mailchimp_dim_template_silver AS
SELECT 
    template_id,
    title,
    subject_line,
    preview_text,
    from_name,
    reply_to,
    authenticate,
    auto_footer,
    auto_tweet,
    drag_and_drop,
    fb_comments,
    inline_css,
    timewarp,
    use_conversation
FROM mailchimp_campaigns_unnest1;

SELECT *
FROM mailchimp_dim_template_silver;

---- mailchimp_fact_email_activity_silver-------
CREATE OR REPLACE TABLE mailchimp_fact_email_activity_silver AS
SELECT 
    email_id,
    campaign_id,
    email_address,
    action,
    action_timestamp,
    ip,
    list_id
FROM mailchimp_email_activity_unnest1;

SELECT *
FROM mailchimp_fact_email_activity_silver;

