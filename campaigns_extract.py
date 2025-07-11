# Extracting campaign data from Mailchimp's API
# API Docs: https://mailchimp.com/developer/marketing/api/
# Python SDK: https://github.com/mailchimp/mailchimp-marketing-python

# Import required libraries
import os  # For file and folder operations
import json  # To save the API data as a JSON file
from datetime import date, timedelta, datetime  # For working with dates and times
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

# Set the date range to only include campaigns from "yesterday"
today = date.today()
yesterday = today - timedelta(days=1)
since_create_time = f"{yesterday}T00:00:00+00:00"
before_create_time = f"{yesterday}T23:59:59+00:00"

# Prepare to save the data. All output files will be stored in the 'data' directory
# Each file will be named with a timestamp to avoid overwriting
timestamp = datetime.now().strftime('%Y%m%d_%H%M')
output_folder = "data"
os.makedirs(output_folder, exist_ok=True)  # Only creates 'data' folder if it doesn't already exist

# Initialize settings based on API documentation
all_campaigns = []  # List to store all campaigns
offset = 0  # Start at the beginning of the dataset
count = 1000  # Fetch up to 1000 records at a time. Deafult is 10, max is 1000

# Fetch campaign data from Mailchimp
try:
    while True:
        # Request a page of campaigns
        response = client.campaigns.list(
            count=count,
            offset=offset,
            since_create_time=since_create_time,
            before_create_time=before_create_time
        )

        #If 'campaigns' doesn’t exist, it returns an empty list [] instead.
        campaigns = response.get('campaigns', []) # Pulls the list of campaigns from the API response and makes sure it doesn’t break if something’s missing.

        # Exit the loop if no campaigns were returned
        if not campaigns:
            break

        all_campaigns.extend(campaigns)  # Add the campaigns to our full list
        offset = offset + count  # skip the previous 1000 and give me the next set
        print(f"Retrieved {len(campaigns)} campaigns... Total so far: {len(all_campaigns)}")

    # Save the results if any campaigns were found
    if all_campaigns: # checking if the list is not empty
        output_file = os.path.join(output_folder, f"campaign_extract_{timestamp}.json") # building file path
        with open(output_file, "w") as f: # creating a temporary variable f
            json.dump(all_campaigns, f, indent=2) # indent=2 makes the JSON nicely formatted
        print(f"Saved {len(all_campaigns)} campaigns to {output_file}")
    else:
        print("No campaigns found for yesterday. No file was created.")

# Handeling API errors
except ApiClientError as error:
    print(f"Mailchimp API error: {error.text}")