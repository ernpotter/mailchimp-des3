# Retrieve .json files and upload json files to S3 bucket

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

# List/find all folders inside 'data' directory
subfolders = [
    folder for folder in os.listdir('data')
    if os.path.isdir(os.path.join('data', folder))
]

# Loop through each subfolder and upload its most recent file
for folder in subfolders:
    folder_path = os.path.join('data', folder)

    try:
        # Get all file paths inside this folder
        files = [
            os.path.join(folder_path, f)
            for f in os.listdir(folder_path)
            if os.path.isfile(os.path.join(folder_path, f))
        ]

        # If there are no files, skip to the next folder
        if not files:
            print(f"No files found in {folder}/")
            continue

        # Get the most recently extracted file
        most_recent_file = max(files, key=os.path.getmtime)
        file_name = os.path.basename(most_recent_file)
        s3_file_path = f"python-import/{folder}/{file_name}"

        try:
            # Upload the file to S3
            s3_client.upload_file(most_recent_file, aws_bucket_name, s3_file_path)
            print(f"Uploaded: {file_name} to {s3_file_path}")

            # Delete the file after successful upload
            os.remove(most_recent_file)

        except Exception as upload_err:
            print(f"Failed to upload {file_name}: {upload_err}")

    except Exception as folder_err:
        print(f"Error reading folder '{folder}': {folder_err}")
