import os
import json
import time
import traceback
from datetime import datetime
import logging
import mailchimp_marketing as MailchimpMarketing
from mailchimp_marketing.api_client import ApiClientError

# Set up logging
logging.basicConfig(
    filename='mailchimp_extraction.log',
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s'
)


def extract_mailchimp_data(start_date, end_date, api_key, output_path='data'):
    """
    Extracts campaign and email activity data from Mailchimp's API for a given date range.
    
    Args:
        start_date (datetime.date): The start date for filtering campaigns
        end_date (datetime.date): The end date for filtering campaigns
        api_key (str): Your Mailchimp API key
        output_path (str): Local folder to save extracted data. Default is 'data'
    
    Returns:
        bool: True if both campaign and email activity data were extracted successfully, False otherwise
    """

    # Convert dates to ISO format expected by Mailchimp API
    since_create_time = f"{start_date}T00:00:00+00:00"
    before_create_time = f"{end_date}T23:59:59+00:00"

    try:
        # Initialize Mailchimp client
        client = MailchimpMarketing.Client()
        client.set_config({
            "api_key": api_key
        })

        # Pull campaign data
        response = client.campaigns.list(
            since_create_time=since_create_time,
            before_create_time=before_create_time
        )

        # Prepare output directories and filenames
        os.makedirs(f"{output_path}/campaigns", exist_ok=True)
        timestamp = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
        campaign_file = f"{output_path}/campaigns/mailchimp_campaigns_{timestamp}.json"

        # Save campaign data
        with open(campaign_file, 'w', encoding='utf-8') as file:
            json.dump(response, file, indent=2)

        print(f"Campaign data saved to {campaign_file}")
        logging.info(f"Campaign data saved to {campaign_file}")

        # Pull email activity data per campaign
        campaigns = response.get("campaigns", [])
        all_activity = []

        for campaign in campaigns:
            campaign_id = campaign.get("id")

            try:
                activity = client.reports.get_email_activity_for_campaign(campaign_id=campaign_id)
                all_activity.append({
                    "campaign_id": campaign_id,
                    "activity": activity
                })
                print(f"Retrieved email activity for: {campaign_id}")

            except ApiClientError as e:
                if e.status_code == 429:
                    print(f"Rate limit hit for {campaign_id} — pausing...")
                    logging.warning(f"Rate limit hit for {campaign_id}")
                    time.sleep(10)
                else:
                    print(f"API error for campaign {campaign_id}: {e}")
                    logging.error(f"API error for campaign {campaign_id}: {e}")

            except Exception as e:
                print(f"Unexpected error for campaign {campaign_id}: {e}")
                logging.error(f"Unexpected error for campaign {campaign_id}: {e}")
                traceback.print_exc()

        # Save email activity
        os.makedirs(f"{output_path}/email_activity", exist_ok=True)
        activity_file = f"{output_path}/email_activity/email_activity_{timestamp}.json"
        with open(activity_file, 'w', encoding='utf-8') as file:
            json.dump(all_activity, file, indent=2)

        print(f"Email activity saved to {activity_file}")
        logging.info(f"Email activity saved to {activity_file}")
        return True

    except ApiClientError as e:
        print(f"Mailchimp API error: {e}")
        logging.error(f"Mailchimp API error: {e}")
        return False

    except Exception as e:
        print(f"Unexpected error during Mailchimp extraction: {e}")
        logging.error(f"Unexpected error: {e}")
        traceback.print_exc()
        return False
