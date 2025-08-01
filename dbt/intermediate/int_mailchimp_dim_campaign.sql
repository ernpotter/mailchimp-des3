with unnested_json as (
select * from {{ ref('int_mailchimp_unnest_email_activity') }}
)

select 
    action,
    campaign_id,
    email_address,
    email_id,
    ip,
    list_id,
    list_is_active,
    action_timestamp,
    extracted_at,
    generation_id,
    raw_id,
    sync_id

from unnested_json
