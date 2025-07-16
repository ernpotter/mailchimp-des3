import os
from datetime import date, timedelta
from dotenv import load_dotenv
from modules.mailchimp_extract_function import extract_mailchimp_data
from modules.mailchimp_load_fucntion import load_to_s3

# Load environment variables
load_dotenv()

# Pull secrets from .env
api_key = os.getenv("MAILCHIMP_API_KEY")
aws_access_key = os.getenv("AWS_ACCESS_KEY")
aws_secret_key = os.getenv("AWS_SECRET_KEY")
bucket_name = os.getenv("AWS_BUCKET_NAME")

# Set extraction window
start_date = date(2025, 4, 1)
end_date = date.today() - timedelta(days=1)

# Extract Mailchimp data
print("Extracting Mailchimp data...")
extract_success = extract_mailchimp_data(start_date, end_date, api_key)

# Load to S3 only if extract worked
if extract_success:
    print("Uploading extracted files to S3...")
    load_success = load_to_s3(
        bucket_name=bucket_name,
        aws_access_key=aws_access_key,
        aws_secret_key=aws_secret_key
    )

    if load_success:
        print("Data extracted and uploaded.")
    else:
        print("Extraction worked, but upload to S3 failed.")
else:
    print("Extraction failed. Skipping S3 upload.")
