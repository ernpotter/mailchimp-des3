# mailchimp-des3

# 📬 Mailchimp ETL Pipeline

A simple Python ETL pipeline that:

- Extracts email campaign and activity data from the Mailchimp API
- Stores the JSON files in a structured local folder (`data/email_activity/`, `data/campaigns/`)
- Uploads only the most recent file from each folder to an S3 bucket
- Deletes the local files after upload

---

## 📁 Folder Structure

