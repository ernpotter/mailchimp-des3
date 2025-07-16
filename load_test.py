# Single JSON file upload to S3 with KMS key

# Load libraries
import boto3
import os
from dotenv import load_dotenv

# Load .env file
load_dotenv()

# Read .env file
aws_access_key=os.getenv('AWS_ACCESS_KEY')
aws_secret_key=os.getenv('AWS_SECRET_KEY')
aws_bucket_name=os.getenv('AWS_BUCKET_NAME')

# print(aws_access_key)
# print(aws_secret_key)
# print(aws_bucket_name)

# Create S3 Client using AWS Credentials
s3_client = boto3.client(
    's3',
    aws_access_key_id=aws_access_key,
    aws_secret_access_key=aws_secret_key
)

# Set file start and end points
local_file_location = "data/campaigns/mailchimp_campaigns_2025-07-13_23-21-08.json"
aws_file_destination = "python-import/campaigns/mailchimp_campaigns_2025-07-13_23-21-08.json"

# Upload file to S3 Bucket
s3_client.upload_file(local_file_location, aws_bucket_name, aws_file_destination)

print("File uploaded")