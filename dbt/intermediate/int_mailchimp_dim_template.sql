with campaigns as (
    select * from {{ ref('stg_mailchimp_campaigns_unnested') }}
)

select
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
from campaigns
