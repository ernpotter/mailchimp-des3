# Mailchimp ELT Pipeline

## 📬 Overview

A simple Python ELT pipeline that:

- Extracts email campaign and activity data from the Mailchimp API
- Stores the JSON files in a structured local folder (`data/email_activity/`, `data/campaigns/`)
- Uploads only the most recent file from each folder to an S3 bucket
- Deletes the local files after upload

---

## 🧠 Functions

### `extract_mailchimp_data()`
- Calls the Mailchimp Marketing API
- Saves JSON responses into:
  - `data/email_activity/`
  - `data/campaigns/`
- Includes error handling and logging

### `load_to_s3()`
- Identifies the most recent `.json` file in each subfolder
- Uploads it to a defined S3 bucket location
- Deletes the local file after successful upload

---

## 🚀 How to Run

1. Clone the repo  
2. Create a `.env` file with your credentials (see below)  
3. Install dependencies  
4. Run the ETL script:

```bash
python mailchimp_extract_and_load.py
```

---

## 🔐 Environment Variables

Create a `.env` file in the root directory with the following:

```dotenv
MAILCHIMP_API_KEY=your_key_here
MAILCHIMP_SERVER_PREFIX=usX
AWS_ACCESS_KEY_ID=your_aws_access_key
AWS_SECRET_ACCESS_KEY=your_aws_secret
AWS_BUCKET_NAME=your_bucket_name
```

---

## ✅ Requirements

Install the required dependencies:

```bash
pip install -r requirements.txt
```

---

## 🧪 Testing Individual Functions

You can test the functions on their own by importing them in an interactive session or script:

```python
from modules.extract_mailchimp_data import extract_mailchimp_data
from modules.load_to_s3 import load_to_s3

extract_mailchimp_data()
load_to_s3()
```

---

## 📌 Notes

- Only the most recent JSON file in each folder is uploaded to S3
- Files are deleted locally after successful upload
- The full process is handled in a single script (mailchimp_extract_and_load.py) that calls both functions

