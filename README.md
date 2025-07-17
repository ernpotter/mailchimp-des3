# Mailchimp ETL Pipeline

## 📬 Overview

A simple Python ETL pipeline that:

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
python run_etl.py


