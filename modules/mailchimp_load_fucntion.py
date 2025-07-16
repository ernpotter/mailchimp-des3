import os
import boto3


def load_to_s3(bucket_name, aws_access_key, aws_secret_key, data_folder='data', s3_folder='python-import'):
    """
    Loads the most recent .json file from each subfolder under the given data directory 
    and uploads it to the specified S3 bucket location. Deletes local files after successful upload.

    Args:
        bucket_name (str): AWS S3 bucket name
        aws_access_key (str): AWS access key
        aws_secret_key (str): AWS secret access key
        data_folder (str): Path to the root local data folder (default: 'data')
        s3_folder (str): S3 key prefix/folder where files should be uploaded (default: 'python-import')

    Returns:
        bool: True if upload succeeded for at least one file, False otherwise
    """

    # Create S3 client
    s3_client = boto3.client(
        's3',
        aws_access_key_id=aws_access_key,
        aws_secret_access_key=aws_secret_key
    )

    success = False  # Track whether any uploads succeeded

    # Get all subfolders in the local data folder
    subfolders = [
        folder for folder in os.listdir(data_folder)
        if os.path.isdir(os.path.join(data_folder, folder))
    ]

    for folder in subfolders:
        folder_path = os.path.join(data_folder, folder)

        try:
            # Get all files in the subfolder
            files = [
                os.path.join(folder_path, f)
                for f in os.listdir(folder_path)
                if os.path.isfile(os.path.join(folder_path, f))
            ]

            if not files:
                print(f"No files found in {folder}/")
                continue

            # Find the most recently modified file
            most_recent_file = max(files, key=os.path.getmtime)
            file_name = os.path.basename(most_recent_file)
            s3_file_path = f"{s3_folder}/{folder}/{file_name}"

            try:
                # Upload to S3
                s3_client.upload_file(most_recent_file, bucket_name, s3_file_path)
                print(f"Uploaded: {file_name} to {s3_file_path}")
                os.remove(most_recent_file)
                success = True

            except Exception as upload_err:
                print(f"Failed to upload {file_name}: {upload_err}")

        except Exception as folder_err:
            print(f"Error reading folder '{folder}': {folder_err}")

    return success