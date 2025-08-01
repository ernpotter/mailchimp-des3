USE DATABASE <your_database>;
USE SCHEMA <your_schema>;

---- 1. Creating stream for bronze tables -----
---- tracks new and changed rows in the flattened bronze layer ----

CREATE OR REPLACE STREAM stream_mailchimp_campaign 
ON TABLE EP_DTHREE_STAGING.MAILCHIMP_CAMPAIGNS_UNNEST1
APPEND_ONLY = FALSE; // so we can track inserts, updates, and deletes 

CREATE OR REPLACE STREAM stream_mailchimp_email_activity 
ON TABLE EP_DTHREE_STAGING.MAILCHIMP_EMAIL_ACTIVITY_UNNEST1
APPEND_ONLY = FALSE;

--- creating view from stream 
--- so we can call the stream multiple times in one stored procedur without losing the data ---
CREATE OR REPLACE VIEW view_mailchimp_campaign AS
SELECT *
FROM stream_mailchimp_campaign;


--- 2. Creating stored procedures using a transient table ----
---- merges changes from the streams into the silver tables ----

---- mailchimp_campaign-------
CREATE OR REPLACE PROCEDURE sp_merge_mailchimp_campaign_refresh()
RETURNS VARCHAR
LANGUAGE SQL
AS
$$
BEGIN

// creating empty transient table 
CREATE TRANSIENT TABLE IF NOT EXISTS tt_mailchimp_campaign ( 
	ARCHIVE_URL VARCHAR(16777216),
	CONTENT_TYPE VARCHAR(16777216),
	CREATE_TIME TIMESTAMP_NTZ(9),
	EMAILS_SENT NUMBER(38,0),
	ID VARCHAR(16777216),
	LONG_ARCHIVE_URL VARCHAR(16777216),
	NEEDS_BLOCK_REFRESH BOOLEAN,
	RESENDABLE BOOLEAN,
	SEND_TIME TIMESTAMP_NTZ(9),
	STATUS VARCHAR(16777216),
	TYPE VARCHAR(16777216),
	WEB_ID NUMBER(38,0),
	CAN_CANCEL BOOLEAN,
	EMAILS_CANCELED NUMBER(38,0),
	DELIVERY_EMAILS_SENT NUMBER(38,0),
	DELIVERY_ENABLED BOOLEAN,
	DELIVERY_STATUS VARCHAR(16777216),
	LIST_ID VARCHAR(16777216),
	LIST_IS_ACTIVE BOOLEAN,
	LIST_NAME VARCHAR(16777216),
	RECIPIENT_COUNT NUMBER(38,0),
	CLICK_RATE FLOAT,
	CLICKS NUMBER(38,0),
	OPEN_RATE FLOAT,
	OPENS NUMBER(38,0),
	SUBSCRIBER_CLICKS NUMBER(38,0),
	UNIQUE_OPENS NUMBER(38,0),
	ECOMMERCE_ORDERS NUMBER(38,0),
	ECOMMERCE_REVENUE FLOAT,
	ECOMMERCE_SPENT FLOAT,
	AUTHENTICATE BOOLEAN,
	AUTO_FOOTER BOOLEAN,
	AUTO_TWEET BOOLEAN,
	DRAG_AND_DROP BOOLEAN,
	FB_COMMENTS BOOLEAN,
	FROM_NAME VARCHAR(16777216),
	INLINE_CSS BOOLEAN,
	PREVIEW_TEXT VARCHAR(16777216),
	REPLY_TO VARCHAR(16777216),
	SUBJECT_LINE VARCHAR(16777216),
	TEMPLATE_ID NUMBER(38,0),
	TIMEWARP BOOLEAN,
	TITLE VARCHAR(16777216),
	USE_CONVERSATION BOOLEAN,
	ECOMM360 BOOLEAN,
	GOAL_TRACKING BOOLEAN,
	HTML_CLICKS BOOLEAN,
	TRACKING_OPENS BOOLEAN,
	TEXT_CLICKS BOOLEAN,
	EXTRACTED_AT TIMESTAMP_NTZ(9),
	GENERATION_ID NUMBER(38,0),
	RAW_ID VARCHAR(16777216),
	SYNC_ID NUMBER(38,0),
    METADATA$ACTION varchar(16777216)
    )
    ;

//take all data from the stream/view
// put into the transient table
INSERT INTO tt_mailchimp_campaign 
SELECT ARCHIVE_URL ,
	CONTENT_TYPE ,
	CREATE_TIME ,
	EMAILS_SENT ,
	ID ,
	LONG_ARCHIVE_URL ,
	NEEDS_BLOCK_REFRESH ,
	RESENDABLE ,
	SEND_TIME ,
	STATUS ,
	TYPE ,
	WEB_ID ,
	CAN_CANCEL ,
	EMAILS_CANCELED ,
	DELIVERY_EMAILS_SENT ,
	DELIVERY_ENABLED ,
	DELIVERY_STATUS ,
	LIST_ID ,
	LIST_IS_ACTIVE ,
	LIST_NAME ,
	RECIPIENT_COUNT ,
	CLICK_RATE ,
	CLICKS ,
	OPEN_RATE ,
	OPENS ,
	SUBSCRIBER_CLICKS ,
	UNIQUE_OPENS ,
	ECOMMERCE_ORDERS ,
	ECOMMERCE_REVENUE ,
	ECOMMERCE_SPENT ,
	AUTHENTICATE ,
	AUTO_FOOTER ,
	AUTO_TWEET ,
	DRAG_AND_DROP ,
	FB_COMMENTS ,
	FROM_NAME ,
	INLINE_CSS ,
	PREVIEW_TEXT ,
	REPLY_TO ,
	SUBJECT_LINE ,
	TEMPLATE_ID ,
	TIMEWARP ,
	TITLE ,
	USE_CONVERSATION ,
	ECOMM360 ,
	GOAL_TRACKING ,
	HTML_CLICKS ,
	TRACKING_OPENS ,
	TEXT_CLICKS ,
	EXTRACTED_AT ,
	GENERATION_ID ,
	RAW_ID ,
	SYNC_ID ,
    METADATA$ACTION 
FROM view_mailchimp_campaign;

// for each merge I'm calling from the transient table 
MERGE INTO mailchimp_dim_campaign_silver AS target
USING (
    SELECT 
        id AS campaign_id,
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
        list_id
    FROM tt_mailchimp_campaign
    WHERE METADATA$ACTION IN ('INSERT', 'UPDATE')
) AS source
ON target.campaign_id = source.campaign_id

WHEN MATCHED THEN UPDATE SET 
    archive_url = source.archive_url,
    long_archive_url = source.long_archive_url,
    content_type = source.content_type,
    create_time = source.create_time,
    send_time = source.send_time,
    status = source.status,
    type = source.type,
    web_id = source.web_id,
    resendable = source.resendable,
    needs_block_refresh = source.needs_block_refresh,
    template_id = source.template_id,
    list_id = source.list_id

WHEN NOT MATCHED THEN INSERT (
    campaign_id, archive_url, long_archive_url, content_type, create_time, send_time,
    status, type, web_id, resendable, needs_block_refresh, template_id, list_id
) VALUES (
    source.campaign_id, source.archive_url, source.long_archive_url, source.content_type, source.create_time,
    source.send_time, source.status, source.type, source.web_id, source.resendable,
    source.needs_block_refresh, source.template_id, source.list_id
);


MERGE INTO mailchimp_dim_delivery_status_silver AS target
USING (
    SELECT 
        id AS campaign_id,
        can_cancel,
        emails_canceled,
        emails_sent,
        delivery_enabled,
        status
    FROM tt_mailchimp_campaign
    WHERE METADATA$ACTION IN ('INSERT', 'UPDATE')
) AS source
ON target.campaign_id = source.campaign_id

WHEN MATCHED THEN UPDATE SET 
    can_cancel = source.can_cancel,
    emails_canceled = source.emails_canceled,
    emails_sent = source.emails_sent,
    delivery_enabled = source.delivery_enabled,
    status = source.status

WHEN NOT MATCHED THEN INSERT (
    campaign_id, can_cancel, emails_canceled, emails_sent, delivery_enabled, status
) VALUES (
    source.campaign_id, source.can_cancel, source.emails_canceled, source.emails_sent,
    source.delivery_enabled, source.status
);


MERGE INTO mailchimp_dim_tracking_silver AS target
USING (
    SELECT 
        id AS campaign_id,
        ecomm360,
        goal_tracking,
        html_clicks,
        opens,
        text_clicks
    FROM tt_mailchimp_campaign
    WHERE METADATA$ACTION IN ('INSERT', 'UPDATE')
) AS source
ON target.campaign_id = source.campaign_id

WHEN MATCHED THEN UPDATE SET 
    ecomm360 = source.ecomm360,
    goal_tracking = source.goal_tracking,
    html_clicks = source.html_clicks,
    opens = source.opens,
    text_clicks = source.text_clicks

WHEN NOT MATCHED THEN INSERT (
    campaign_id, ecomm360, goal_tracking, html_clicks, opens, text_clicks
) VALUES (
    source.campaign_id, source.ecomm360, source.goal_tracking, source.html_clicks,
    source.opens, source.text_clicks
);


MERGE INTO mailchimp_fact_campaign_report_summary_silver AS target
USING (
    SELECT 
        id AS campaign_id,
        click_rate,
        clicks,
        open_rate,
        opens,
        subscriber_clicks,
        unique_opens,
        ecommerce_orders,
        ecommerce_revenue,
        ecommerce_spent
    FROM tt_mailchimp_campaign
    WHERE METADATA$ACTION IN ('INSERT', 'UPDATE')
) AS source
ON target.campaign_id = source.campaign_id

WHEN MATCHED THEN UPDATE SET 
    click_rate = source.click_rate,
    clicks = source.clicks,
    open_rate = source.open_rate,
    opens = source.opens,
    subscriber_clicks = source.subscriber_clicks,
    unique_opens = source.unique_opens,
    ecommerce_orders = source.ecommerce_orders,
    ecommerce_revenue = source.ecommerce_revenue,
    ecommerce_spent = source.ecommerce_spent

WHEN NOT MATCHED THEN INSERT (
    campaign_id, click_rate, clicks, open_rate, opens, subscriber_clicks,
    unique_opens, ecommerce_orders, ecommerce_revenue, ecommerce_spent
) VALUES (
    source.campaign_id, source.click_rate, source.clicks, source.open_rate, source.opens,
    source.subscriber_clicks, source.unique_opens, source.ecommerce_orders,
    source.ecommerce_revenue, source.ecommerce_spent
);


MERGE INTO mailchimp_dim_list_silver AS target
USING (
    SELECT 
        list_id,
        list_name,
        list_is_active,
        recipient_count
    FROM tt_mailchimp_campaign
    WHERE METADATA$ACTION IN ('INSERT', 'UPDATE')
) AS source
ON target.list_id = source.list_id

WHEN MATCHED THEN UPDATE SET 
    list_name = source.list_name,
    list_is_active = source.list_is_active,
    recipient_count = source.recipient_count

WHEN NOT MATCHED THEN INSERT (
    list_id, list_name, list_is_active, recipient_count
) VALUES (
    source.list_id, source.list_name, source.list_is_active, source.recipient_count
);


MERGE INTO mailchimp_dim_template_silver AS target
USING (
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
    FROM tt_mailchimp_campaign
    WHERE METADATA$ACTION IN ('INSERT', 'UPDATE')
) AS source
ON target.template_id = source.template_id

WHEN MATCHED THEN UPDATE SET 
    title = source.title,
    subject_line = source.subject_line,
    preview_text = source.preview_text,
    from_name = source.from_name,
    reply_to = source.reply_to,
    authenticate = source.authenticate,
    auto_footer = source.auto_footer,
    auto_tweet = source.auto_tweet,
    drag_and_drop = source.drag_and_drop,
    fb_comments = source.fb_comments,
    inline_css = source.inline_css,
    timewarp = source.timewarp,
    use_conversation = source.use_conversation

WHEN NOT MATCHED THEN INSERT (
    template_id, title, subject_line, preview_text, from_name, reply_to,
    authenticate, auto_footer, auto_tweet, drag_and_drop, fb_comments,
    inline_css, timewarp, use_conversation
) VALUES (
    source.template_id, source.title, source.subject_line, source.preview_text, source.from_name, source.reply_to,
    source.authenticate, source.auto_footer, source.auto_tweet, source.drag_and_drop, source.fb_comments,
    source.inline_css, source.timewarp, source.use_conversation
);

// delete the data within the transient table at the end, but keeping the empty table
// if this every fails to run midway through, the data will still be there, so we'd only have to rerun the procedure 
TRUNCATE TABLE tt_mailchimp_campaign;
    RETURN 'I did it!';

END;
$$;


CALL sp_merge_mailchimp_campaign_refresh();

------ 3. Creating task to update stored procedure -------
CREATE OR REPLACE TASK task_merge_mailchimp_campaign
  WAREHOUSE = <your_warehouse_name>
  SCHEDULE = 'USING CRON 0 * * * * UTC' -- optional: every hour
  WHEN
    SYSTEM$STREAM_HAS_DATA('stream_mailchimp_campaign')
AS
  CALL sp_merge_mailchimp_campaign_refresh();


--- Repeat steps 2-3 for email_activity
