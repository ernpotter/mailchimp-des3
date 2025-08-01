USE DATABASE TIL_DATA_ENGINEERING;
USE SCHEMA ep_dthree_staging;

--- create a storage integration-----
CREATE OR REPLACE STORAGE INTEGRATION EP_MAILCHIMP_AIRBYTE_STOR_INT
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  ENABLED = TRUE
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::<aws_account_id>:role/<iam_role_name>'
  STORAGE_ALLOWED_LOCATIONS = ('s3://<bucket_name>/<folder_name>/');

---- describe the integration and retrieve the required informationl AWS External ID, AWS IAM User ARN ----
DESC INTEGRATION EP_MAILCHIMP_AIRBYTE_STOR_INT;



--- create an external stage for the S3 bucket-----

CREATE OR REPLACE FILE FORMAT ep_json_format
  TYPE = 'JSON'
  STRIP_OUTER_ARRAY = FALSE;

CREATE OR REPLACE STAGE mailchimp_airbyte_st_ep
  STORAGE_INTEGRATION = EP_MAILCHIMP_AIRBYTE_STOR_INT
  URL = 's3://<bucket_name>/<folder_name>/'
  FILE_FORMAT = ep_jsonl_format;


---- see all objects on the stage (in the S3 bucket) -----
LIST @mailchimp_airbyte_st_ep;


----- copy files into raw table -----------------------

--------- CAMPAIGNS -----------------
CREATE OR REPLACE TABLE mailchimp_campaigns_raw_airbyte (
  json_data VARIANT
);

COPY INTO mailchimp_campaigns_raw_airbyte 
FROM @mailchimp_airbyte_st_ep/MAILCHIMP/campaigns/
FILE_FORMAT = (FORMAT_NAME = ep_jsonl_format);

SELECT *
FROM mailchimp_campaigns_raw_airbyte;

--------- EMAIL ACTIVITY -----------------
CREATE OR REPLACE TABLE mailchimp_email_activity_raw_airbyte (
  json_data VARIANT
);

COPY INTO mailchimp_email_activity_raw_airbyte 
FROM @mailchimp_airbyte_st_ep/MAILCHIMP/email_activity/
FILE_FORMAT = (FORMAT_NAME = ep_jsonl_format);

SELECT *
FROM mailchimp_email_activity_raw_airbyte;


--------- LISTS -----------------
CREATE OR REPLACE TABLE mailchimp_lists_raw_airbyte (
  json_data VARIANT
);

COPY INTO mailchimp_lists_raw_airbyte 
FROM @mailchimp_airbyte_st_ep/MAILCHIMP/lists/
FILE_FORMAT = (FORMAT_NAME = ep_jsonl_format);

SELECT *
FROM mailchimp_lists_raw_airbyte;


--------- LIST MEMBERS -----------------
CREATE OR REPLACE TABLE mailchimp_list_members_raw_airbyte (
  json_data VARIANT
);

COPY INTO mailchimp_list_members_raw_airbyte
FROM @mailchimp_airbyte_st_ep/MAILCHIMP/list_members/
FILE_FORMAT = (FORMAT_NAME = ep_jsonl_format);

SELECT *
FROM mailchimp_list_members_raw_airbyte;


--------- REPORTS -----------------
CREATE OR REPLACE TABLE mailchimp_reports_raw_airbyte (
  json_data VARIANT
);

COPY INTO mailchimp_reports_raw_airbyte
FROM @mailchimp_airbyte_st_ep/MAILCHIMP/reports/
FILE_FORMAT = (FORMAT_NAME = ep_jsonl_format);

SELECT *
FROM mailchimp_reports_raw_airbyte;


--------- UNSUBSCRIBES -----------------
CREATE OR REPLACE TABLE mailchimp_unsubscribes_raw_airbyte (
  json_data VARIANT
);

COPY INTO mailchimp_unsubscribes_raw_airbyte
FROM @mailchimp_airbyte_st_ep/MAILCHIMP/unsubscribes/
FILE_FORMAT = (FORMAT_NAME = ep_json_format);

SELECT *
FROM mailchimp_unsubscribes_raw_airbyte;
