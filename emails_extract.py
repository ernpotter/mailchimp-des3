# Extracting email activity data from Mailchimp's API
# API Docs: https://mailchimp.com/developer/marketing/api/
# Python SDK: https://github.com/mailchimp/mailchimp-marketing-python

# Import required libraries
import os  # For file and folder operations
import json  # To save the API data as a JSON file
import glob  # To find the most recent campaign file
from datetime import datetime  # For timestamps on output files
from dotenv import load_dotenv  # To securely load API credentials from a .env file
import mailchimp_marketing as MailchimpMarketing  # Mailchimp's official Python SDK
from mailchimp_marketing.api_client import ApiClientError  # For handling API errors

# Load environment variables from the .env file
load_dotenv()

# Read API key and server prefix from the environment
api_key = os.getenv("MAILCHIMP_API_KEY")
server_prefix = os.getenv("MAILCHIMP_SERVER_PREFIX")

# Set up the Mailchimp client
client = MailchimpMarketing.Client()
client.set_config({
    "api_key": api_key,
    "server": server_prefix
})

# Prepare to save the data. All output files will be stored in the 'email_data' directory
# Each file will be named with a timestamp to avoid overwriting
timestamp = datetime.now().strftime('%Y%m%d_%H%M')
output_folder = "email_data"
os.makedirs(output_folder, exist_ok=True)  # Only creates 'email_data' folder if it doesn't already exist

# Look for the most recent campaign_extract_*.json file in the campaign_data folder
campaign_files = glob.glob("campaign_data/campaign_extract_*.json")
if not campaign_files:
    raise FileNotFoundError("No campaign files found in 'campaign_data' folder.")

# Get the file with the most recent creation time
campaign_path = max(campaign_files, key=os.path.getctime)

# Load campaign data from the selected file
with open(campaign_path, "r") as f:
    campaigns = json.load(f)

# Create an empty list to store email activity
all_email_activities = []

# Set up pagination
count = 1000  # Mailchimp allows up to 1000 results per page

# Loop through each campaign and get email activity
try:
    for campaign in campaigns:
        campaign_id = campaign.get('id')
        offset = 0  # Start at the beginning of the result set

        while True:
            # Request a page of email activity for the current campaign
            response = client.reports.get_email_activity_for_campaign(
                campaign_id=campaign_id,
                count=count,
                offset=offset
            )

            emails = response.get('emails', [])

            # Exit the loop if no more email activity
            if not emails:
                break

            # Add campaign ID to each record to trace source
            for email in emails:
                email['campaign_id'] = campaign_id
                all_email_activities.append(email)

            print(f"Retrieved {len(emails)} emails for campaign {campaign_id}")
            offset += count  # Skip previously fetched emails

    # Save the results if any email activity was found
    if all_email_activities:
        output_file = os.path.join(output_folder, f"email_activity_extract_{timestamp}.json")
        with open(output_file, "w", encoding="utf-8") as f:
            json.dump(all_email_activities, f, indent=2)
        print(f"Saved {len(all_email_activities)} email activity records to {output_file}")
    else:
        print("No email activity found. No file was created.")

# Handle Mailchimp API errors
except ApiClientError as error:
    print(f"Mailchimp API error: {error.text}")