from dotenv import load_dotenv
import os
import mailchimp_marketing as MailchimpMarketing
from mailchimp_marketing import Client
from mailchimp_marketing.api_client import ApiClientError
import json
from datetime import date, timedelta

# Load the env variables
load_dotenv()
api_key = os.getenv('MAILCHIMP_API_KEY')
server_prefix = os.getenv('MAILCHIMP_SERVER_PREFIX')

client = MailchimpMarketing.Client() #Initialize the client
client.set_config({
    "api_key": api_key,
    "server": server_prefix  # Configure client with API key
})


response = client.ping.get()
print(response)
