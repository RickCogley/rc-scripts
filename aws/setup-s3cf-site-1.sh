#!/bin/bash

# Set your domain here by feeding it to the script as first arg dollar 1
# For example, live.cogley.info or rick.cogley.info
YOUR_DOMAIN="$1"
REGION="us-east-1"
# Don't change these
BUCKET_NAME="${YOUR_DOMAIN}-cdn"
LOG_BUCKET_NAME="${BUCKET_NAME}-logs"

echo "Domain: $YOUR_DOMAIN"
echo "Region: $REGION"
echo "Site Bucket: $BUCKET_NAME"
echo "Log Bucket: $LOG_BUCKET_NAME"

# Make an s3 bucket for the site
# aws s3 mb s3://$BUCKET_NAME --region $REGION
echo "Creating Site Bucket: $BUCKET_NAME"
aws s3api create-bucket --bucket $BUCKET_NAME --acl public-read --region $REGION
# Make an s3 bucket for the logs
# aws s3 mb s3://$LOG_BUCKET_NAME --region $REGION
echo "Creating Log Bucket: $LOG_BUCKET_NAME"
aws s3api create-bucket --bucket $LOG_BUCKET_NAME --acl public-read --region $REGION

# Create public read policy for site bucket
# The final goto word in a heredoc must NOT have a space after
echo "Create public read policy for site bucket"
cat <<eosa > publicreadpolicy.json
{
  "Version":"2012-10-17",
  "Statement":[{
    "Sid":"PublicReadGetObject",
        "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::$BUCKET_NAME/*"
      ]
    }
  ]
}
eosa
cat publicreadpolicy.json

# Apply public read policy to site bucket 
echo "Apply public read policy to site bucket"
aws s3api put-bucket-policy --bucket $BUCKET_NAME --policy file://publicreadpolicy.json

# Let AWS to write the logs to log bucket
echo "Allow AWS to write the logs to the log bucket"
aws s3api put-bucket-acl --bucket $LOG_BUCKET_NAME --grant-write 'URI="http://acs.amazonaws.com/groups/s3/LogDelivery"' --grant-read-acp 'URI="http://acs.amazonaws.com/groups/s3/LogDelivery"'

# Setup logging
echo "Setup logging"
LOG_POLICY="{\"LoggingEnabled\":{\"TargetBucket\":\"$LOG_BUCKET_NAME\",\"TargetPrefix\":\"$BUCKET_NAME\"}}"
aws s3api put-bucket-logging --bucket $BUCKET_NAME --bucket-logging-status $LOG_POLICY

# Create website config for redirecting
# The final goto word in a heredoc must NOT have a space after
echo "Create website config for redirecting"
cat <<eosb > website.json
{
    "IndexDocument": {
        "Suffix": "index.html"
    },
    "ErrorDocument": {
        "Key": "404.html"
    },
    "RoutingRules": [
        {
            "Redirect": {
                "ReplaceKeyWith": "index.html"
            },
            "Condition": {
                "KeyPrefixEquals": "/"
            }
        }
    ]
} 
eosb
cat website.json

# Apply website config for redirecting
echo "Apply website config for redirecting"
aws s3api put-bucket-website --bucket $BUCKET_NAME --website-configuration file://website.json

# Get SSL certs
echo "Request SSL certificate"
aws acm request-certificate --domain-name $YOUR_DOMAIN --subject-alternative-names "www.$YOUR_DOMAIN" --idempotency-token "`date +%s`"

# Issue command to see ARN to use in next step
echo "Assuming you have webmaster@$DOMAIN working, approve the emails that come regarding the certificates."
aws acm list-certificates --certificate-statuses ISSUED
echo "Won't work until you approve the email. The ARN of the domain from this list is used in the next script."

# Cleanup
echo "Cleanup"
rm -rf publicreadpolicy.json
rm -rf website.json 
