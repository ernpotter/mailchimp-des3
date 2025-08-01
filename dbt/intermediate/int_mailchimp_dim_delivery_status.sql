with campaigns as (
    select * from {{ ref('stg_mailchimp_campaigns_unnested') }}
)

select
    id as campaign_id,
    can_cancel,
    emails_canceled,
    emails_sent,
    delivery_enabled,
    status
from campaigns
