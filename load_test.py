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


