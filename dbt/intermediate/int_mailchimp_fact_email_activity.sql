with email_activity as (
    select * from {{ ref('stg_mailchimp_email_activity_unnested') }}
)

select
    email_id,
    campaign_id,
    email_address,
    action,
    action_timestamp,
    ip,
    list_id
from email_activity
