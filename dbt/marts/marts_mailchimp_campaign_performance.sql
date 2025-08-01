WITH campaign AS (
    SELECT * FROM {{ ref('int_mailchimp_dim_campaign') }}
),

report AS (
    SELECT * FROM {{ ref('int_mailchimp_fact_campaign_report_summary') }}
),

delivery AS (
    SELECT * FROM {{ ref('int_mailchimp_dim_delivery_status') }}
),

tracking AS (
    SELECT * FROM {{ ref('int_mailchimp_dim_tracking') }}
),

list AS (
    SELECT * FROM {{ ref('int_mailchimp_dim_list') }}
),

template AS (
    SELECT * FROM {{ ref('int_mailchimp_dim_template') }}
),

email_activity AS (
    SELECT
        campaign_id,
        COUNT(*) AS total_actions,
        COUNT(DISTINCT email_id) AS unique_emails,
        COUNT_IF(action = 'open') AS open_actions,
        COUNT_IF(action = 'click') AS click_actions,
        MIN(action_timestamp) AS first_action_time,
        MAX(action_timestamp) AS last_action_time
    FROM {{ ref('int_mailchimp_fact_email_activity') }}
    group by campaign_id

)

SELECT DISTINCT
    -- Campaign Info
    c.campaign_id,
    c.archive_url,
    c.long_archive_url,
    c.content_type,
    c.create_time,
    c.send_time,
    c.status AS campaign_status,
    c.type AS campaign_type,
    c.web_id,
    c.resendable,
    c.needs_block_refresh,
    c.template_id,
    c.list_id,

    -- Report Summary
    r.click_rate,
    r.clicks,
    r.open_rate,
    r.opens,
    r.subscriber_clicks,
    r.unique_opens,
    r.ecommerce_orders,
    r.ecommerce_revenue,
    r.ecommerce_spent,

    -- Delivery Status
    d.can_cancel,
    d.emails_canceled,
    d.emails_sent AS delivery_emails_sent,
    d.delivery_enabled,
    d.status AS delivery_status,

    -- Tracking
    tr.ecomm360,
    tr.goal_tracking,
    tr.html_clicks,
    tr.opens AS tracking_opens,
    tr.text_clicks,

    -- List Info
    l.list_name,
    l.list_is_active,
    l.recipient_count,

    -- Template Info
    t.title AS template_title,
    t.subject_line,
    t.preview_text,
    t.from_name,
    t.reply_to,
    t.authenticate,
    t.auto_footer,
    t.auto_tweet,
    t.drag_and_drop,
    t.fb_comments,
    t.inline_css,
    t.timewarp,
    t.use_conversation,

    -- Email Activity (Aggregated)
    ea.total_actions,
    ea.unique_emails,
    ea.open_actions,
    ea.click_actions,
    ea.first_action_time,
    ea.last_action_time

FROM campaign c
LEFT JOIN report r ON c.campaign_id = r.campaign_id
LEFT JOIN delivery d ON c.campaign_id = d.campaign_id
LEFT JOIN tracking tr ON c.campaign_id = tr.campaign_id
LEFT JOIN list l ON c.list_id = l.list_id
LEFT JOIN template t ON c.template_id = t.template_id
INNER JOIN email_activity ea ON c.campaign_id = ea.campaign_id
