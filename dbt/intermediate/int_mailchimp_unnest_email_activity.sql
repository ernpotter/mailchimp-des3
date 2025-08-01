with 

json as (

    select * from {{ ref('stg_mailchimp___email_activity') }}

)

select 
  -- Top-level fields from _airbyte_data
  json_data:"_airbyte_data":"action"::STRING AS action,
  json_data:"_airbyte_data":"campaign_id"::STRING AS campaign_id,
  json_data:"_airbyte_data":"email_address"::STRING AS email_address,
  json_data:"_airbyte_data":"email_id"::STRING AS email_id,
  json_data:"_airbyte_data":"ip"::STRING AS ip,
  json_data:"_airbyte_data":"list_id"::STRING AS list_id,
  json_data:"_airbyte_data":"list_is_active"::BOOLEAN AS list_is_active,
  json_data:"_airbyte_data":"timestamp"::TIMESTAMP_TZ AS action_timestamp,

  -- Metadata fields
  TO_TIMESTAMP_LTZ(json_data:"_airbyte_extracted_at"::NUMBER / 1000) AS extracted_at,
  json_data:"_airbyte_generation_id"::INT AS generation_id,
  json_data:"_airbyte_raw_id"::STRING AS raw_id,
  json_data:"_airbyte_meta":sync_id::INT AS sync_id

from json
