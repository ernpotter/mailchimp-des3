with 

source as (

    select * from {{ source('mailchimp', 'mailchimp_email_activity_raw_airbyte') }}

),

renamed as (

    select
        json_data

    from source

)

select * from renamed
