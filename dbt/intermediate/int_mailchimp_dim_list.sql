with campaigns as (
    select * from {{ ref('stg_mailchimp_campaigns_unnested') }}
)

select
    list_id,
    list_name,
    list_is_active,
    recipient_count
from campaigns
