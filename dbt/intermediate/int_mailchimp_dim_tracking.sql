with campaigns as (
    select * from {{ ref('stg_mailchimp_campaigns_unnested') }}
)

select
    id as campaign_id,
    ecomm360,
    goal_tracking,
    html_clicks,
    opens,
    text_clicks
from campaigns
