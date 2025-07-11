# Verifying connection to MailChimp's API
# https://github.com/mailchimp/mailchimp-marketing-python

# Importing required libraies 
from dotenv import load_dotenv
import os
import mailchimp_marketing as MailchimpMarketing

# Load the env variables so we can grab the API keys
load_dotenv()

# Read the .env file and load the key and server prefix from
api_key = os.getenv('MAILCHIMP_API_KEY')
server_prefix = os.getenv('MAILCHIMP_SERVER_PREFIX')

# Initialize the client. Creates a new instance of the mailchimp client so we can make API calls 
client = MailchimpMarketing.Client()

# Configure the client with the API key and server prefix
client.set_config({
    "api_key": api_key,
    "server": server_prefix
})
# Pinging the API to verify connection. Hey Mailchimp, can you hear me?
response = client.ping.get()
print(response)
