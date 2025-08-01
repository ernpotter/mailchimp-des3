with 

source as (

    select * from {{ source('mailchimp', 'mailchimp_campaigns_raw_airbyte') }}

),

renamed as (

    select
        json_data
        
    from source

)

select * from renamed
