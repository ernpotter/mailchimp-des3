with campaigns as (
    select * from {{ ref('stg_mailchimp_campaigns_unnested') }}
)

select
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
from campaigns
