#!/bin/bash

# Set your domain here by feeding it to the script as dollar 1
# For example, live.cogley.info or rick.cogley.info
YOUR_DOMAIN="$1"

REGION="us-east-1"
# Don't change these
BUCKET_NAME="${YOUR_DOMAIN}-cdn"
LOG_BUCKET_NAME="${BUCKET_NAME}-logs"
CALLER_REF="`date +%s`" # current second

# Next needs jq
command -v jq >/dev/null 2>&1 || { echo "Utility jq is required but it's not installed. Aborting." >&2; exit 1; }

# Needs first script to be run for this to work
# ARN should be something like arn:aws:acm:us-east-1:7123456789:certificate/abc12345-asdf-asdf-asdf-asdf9876asdf
SSL_ARN=`aws acm list-certificates --certificate-statuses ISSUED | jq --arg dn $YOUR_DOMAIN '.CertificateSummaryList[] | select(.DomainName==$dn) | .CertificateArn' | tr -d '"'`

echo "Domain: $YOUR_DOMAIN"
echo "Region: $REGION"
echo "Site Bucket: $BUCKET_NAME"
echo "Log Bucket: $LOG_BUCKET_NAME"
echo "SSL arn: $SSL_ARN"

# The final goto word (here eos) in a heredoc must NOT have a space after
echo "Create cloudfront distribution config"
cat <<eos > distroConfig.json  
{
    "Comment": "$BUCKET_NAME Static Hosting", 
    "Logging": {
        "Bucket": "$LOG_BUCKET_NAME.s3.amazonaws.com", 
        "Prefix": "${BUCKET_NAME}-cf/", 
        "Enabled": true,
        "IncludeCookies": false
    }, 
    "Origins": {
        "Quantity": 1,
        "Items": [
            {
                "Id":"$BUCKET_NAME-origin",
                "OriginPath": "", 
                "CustomOriginConfig": {
                    "OriginProtocolPolicy": "http-only", 
                    "HTTPPort": 80, 
                    "OriginSslProtocols": {
                        "Quantity": 3,
                        "Items": [
                            "TLSv1", 
                            "TLSv1.1", 
                            "TLSv1.2"
                        ]
                    }, 
                    "HTTPSPort": 443
                }, 
                "DomainName": "$BUCKET_NAME.s3-website-$REGION.amazonaws.com"
            }
        ]
    }, 
    "DefaultRootObject": "index.html", 
    "PriceClass": "PriceClass_All", 
    "Enabled": true, 
    "CallerReference": "$CALLER_REF",
    "DefaultCacheBehavior": {
        "TargetOriginId": "$BUCKET_NAME-origin",
        "ViewerProtocolPolicy": "redirect-to-https", 
        "DefaultTTL": 1800,
        "AllowedMethods": {
            "Quantity": 2,
            "Items": [
                "HEAD", 
                "GET"
            ], 
            "CachedMethods": {
                "Quantity": 2,
                "Items": [
                    "HEAD", 
                    "GET"
                ]
            }
        }, 
        "MinTTL": 0, 
        "Compress": true,
        "ForwardedValues": {
            "Headers": {
                "Quantity": 0
            }, 
            "Cookies": {
                "Forward": "none"
            }, 
            "QueryString": false
        },
        "TrustedSigners": {
            "Enabled": false, 
            "Quantity": 0
        }
    }, 
    "ViewerCertificate": {
        "SSLSupportMethod": "sni-only", 
        "ACMCertificateArn": "$SSL_ARN", 
        "MinimumProtocolVersion": "TLSv1", 
        "Certificate": "$SSL_ARN", 
        "CertificateSource": "acm"
    }, 
    "CustomErrorResponses": {
        "Quantity": 2,
        "Items": [
            {
                "ErrorCode": 403, 
                "ResponsePagePath": "/404.html", 
                "ResponseCode": "404",
                "ErrorCachingMinTTL": 300
            }, 
            {
                "ErrorCode": 404, 
                "ResponsePagePath": "/404.html", 
                "ResponseCode": "404",
                "ErrorCachingMinTTL": 300
            }
        ]
    }, 
    "Aliases": {
        "Quantity": 2,
        "Items": [
            "$YOUR_DOMAIN", 
            "www.$YOUR_DOMAIN"
        ]
    }
}
eos

# Now apply the distroConfig file
echo "Apply cloudfront distribution config"
aws cloudfront create-distribution --distribution-config file://distroConfig.json

## Get the domain name to use in Route53
aws cloudfront list-distributions --query 'DistributionList.Items[].{id:Id,comment:Comment,domain:DomainName}'
echo "Get the domain name for use in Route53, something like asd8f765asd8.cloudfront.net"
echo "Set an A record for your domain $YOUR_DOMAIN as an ALIAS with the ALIAS target as the cf distribution url"

## Cleanup
echo "Cleanup"
rm -rf distroConfig.json

