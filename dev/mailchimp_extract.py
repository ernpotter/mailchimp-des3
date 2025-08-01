# Extracting campaign and email activity data from Mailchimp using the Mailchimp Marketing API
# https://github.com/mailchimp/mailchimp-marketing-python

import os # Interact with the operating system (e.g. read env vars)
import json # Save API data to JSON files
import time # Handle rate limiting (for time.sleep() in error handeling
import traceback # Print full error tracebacks for debugging
from datetime import date, timedelta, datetime  # Handle date ranges and timestamps
from dotenv import load_dotenv  # Load environment variables from a .env file
import logging # To create log of each run to help trace what failed and why
import mailchimp_marketing as MailchimpMarketing  # Mailchimp Marketing API client
from mailchimp_marketing.api_client import ApiClientError  # Specific error class for handling Mailchimp API issues

# logging to help me debug rate limits, schema changes, and system errors
logging.basicConfig(
    filename='logs/mailchimp_extraction.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)

# Load the env variables so we can grab the API key
load_dotenv()

# Read the .env file and load the key and server prefix from
api_key = os.getenv('MAILCHIMP_API_KEY')
#server_prefix = os.getenv('MAILCHIMP_SERVER_PREFIX')

# Set the date range to only include campaigns from april 1 to yesterday
start_date = date(2025, 4, 1)
end_date = date.today() - timedelta(days=1)
since_create_time = f"{start_date}T00:00:00+00:00"
before_create_time = f"{end_date}T23:59:59+00:00"

# ------------------------
# Campaign data
# ------------------------
try: 
    # Initialize the client. Creates a new instance of the mailchimp client so we can make API calls 
    client = MailchimpMarketing.Client()
    # Configure the client with the API key and server prefix
    client.set_config({
        "api_key": api_key,
        #"server": server_prefix
    })
    # Pinging the API to verify connection. Hey Mailchimp, can you hear me?
    response = client.campaigns.list(
        since_create_time=since_create_time ,
        before_create_time=before_create_time
    )
    
    # Create 'data' folder and 'campaigns' subfolder if it doesn't exist
    os.makedirs('data/campaigns', exist_ok=True)

    # Create a timestamped filename
    timestamp = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
    filename = f"data/campaigns/mailchimp_campaigns_{timestamp}.json"

    # Save the response to the file
    with open(filename, 'w', encoding='utf-8') as file:
        json.dump(response, file, indent=2)

    print(f"Campaign data saved to {filename}")
    logging.info(f"Campaign data saved to {filename}")

# ----------------
# Error handeling
# ----------------

# detects schema changes in the API response
except KeyError as e:
    print(f"Schema changed — missing key: {e}")
    logging.error(f"Schema changed — missing key: {e}")

# Any errors specifically returned by the Mailchimp Marketing API
except ApiClientError as e:
    if e.status_code == 429:
        print("Rate limit hit — waiting 10 seconds...")
        logging.error("Rate limit hit — waiting 10 seconds...")
        time.sleep(10)
    else:
        print(f"API error while retrieving campaigns: {e}")
        logging.error(f"API error while retrieving campaigns: {e}")
        response = None

# Network-level issues (no internet, timeout, DNS failure)
except ConnectionError as e:
    print(f"Network error while retrieving campaigns: {e}")
    logging.error(f"Network error while retrieving campaigns: {e}")
    response = None

# Catches everything (generic Python errors). Anything not caught above
except Exception as e:
    print(f"Unexpected error while extracting campaign data: {e}")
    logging.error(f"Unexpected error while extracting campaign data: {e}")
    traceback.print_exc() # will print out exactly where and why the error happened
    response = None # So we don’t try to extract email activity if it failed


# ----------------------
# Email Activity data
# ----------------------
if response: 
    try: 

        # Give me the value under the 'campaigns' key — and if it doesn't exist, give me an empty list [] instead.
        campaigns = response.get("campaigns", [])

        # Creating an empty list/ preparing a container to collect all the email activity data from each campaign
        all_activity = []

        # for loop to get campaign id from each campaign        
        for campaign in campaigns:
            campaign_id = campaign.get("id")      

            try:
                activity = client.reports.get_email_activity_for_campaign(campaign_id=campaign_id)
                # Add campaign-level metadata and activity
                all_activity.append({
                    "campaign_id": campaign_id,
                    "activity": activity
                })
                print(f"Retrieved email activity for: {campaign_id}")
                
            # ----------------
            # Error handeling
            # ----------------

            # detects schema change
            except KeyError as e:
                print(f"Schema changed — missing key: {e}")
                logging.error(f"Schema changed — missing key: {e}")

            # Any errors specifically returned by the Mailchimp Marketing API
            except ApiClientError as e:
                if e.status_code == 429:
                    print(f"Rate limit hit while getting activity for {campaign_id} — pausing...")
                    logging.error(f"Rate limit hit while getting activity for {campaign_id} — pausing...")
                    time.sleep(10)
                else:
                    print(f"API error for campaign {campaign_id}: {e}")
                    logging.error(f"API error for campaign {campaign_id}: {e}")

            # Network-level issues (no internet, timeout, DNS failure)
            except ConnectionError as e:
                print(f"Network issue while processing {campaign_id}: {e}")
                logging.error(f"Network issue while processing {campaign_id}: {e}")

            # Catches everything (generic Python errors). Anything not caught above
            except Exception as e:
                print(f"Unexpected error for {campaign_id}: {e}")
                logging.error(f"Unexpected error while extracting email activity data: {e}")
                traceback.print_exc()
    
        # Create 'email_activity' subfolder before saving
        os.makedirs('data/email_activity', exist_ok=True)

        # Save all activity to a single file
        activity_filename = f"data/email_activity/email_activity_{timestamp}.json"
        with open(activity_filename, 'w', encoding='utf-8') as file:
            json.dump(all_activity, file, indent=2)

        print(f"Email activity saved to {activity_filename}")
        logging.info(f"Email activity saved to {activity_filename}")

    
    # Catches everything (generic Python errors). Anything not caught above
    except Exception as e:
        print(f"Unexpected error occured while extracting email activity data: {e}")
        logging.info(f"Unexpected error occured while extracting email activity data: {e}")
        traceback.print_exc()