import os
from dotenv import load_dotenv
from modules.mailchimp_load_fucntion import load_to_s3

# Load environment variables from .env file
load_dotenv()

# Grab AWS credentials and bucket name
aws_access_key = os.getenv("AWS_ACCESS_KEY")
aws_secret_key = os.getenv("AWS_SECRET_KEY")
bucket_name = os.getenv("AWS_BUCKET_NAME")

# Run the load function
success = load_to_s3(
    bucket_name=bucket_name,
    aws_access_key=aws_access_key,
    aws_secret_key=aws_secret_key
)

# Print result
print("✅ Test succeeded!" if success else "❌ Test failed or no files found.")

from datetime import date, timedelta
from dotenv import load_dotenv
import os

from modules.mailchimp_extract_function import extract_mailchimp_data

# Load your .env variables
load_dotenv()

# Get your Mailchimp API key
api_key = os.getenv("MAILCHIMP_API_KEY")

# Define date range
start_date = date(2025, 4, 1)
end_date = date.today() - timedelta(days=1)

# Run the extraction
success = extract_mailchimp_data(start_date, end_date, api_key)

# Print the result
print("✅ Extraction succeeded!" if success else "❌ Extraction failed.")
