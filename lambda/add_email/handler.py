import json
import logging
import boto3
import os


logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context) -> dict:
    body = json.loads(event["body"])
    logger.info(f"Parsed body: {body}")

    client = boto3.client("dynamodb", 
                          endpoint_url = os.getenv("DYNAMO_DB_ENDPOINT"), 
                          region_name = "us-east-1"
                        )
    logger.info(f'Connected to DynamoDB: ${client.list_tables()}')

    # Validate the input
    email = body.get("email")
    logger.info(f"Validating email: {email}")

    if not validate_email(email):
        logger.error(f"Invalid email address: {email}")
        return {
            "statusCode": 422,  # Unprocessable Entity
            "body": json.dumps({
                "error": "Invalid email address" 
            }, default=str)
        }
    
    client.put_item(
        TableName="emails",
        Item={
            "slackId": {"S": body["slackId"]},
            "email": {"S": email}
        }
    )
    
    return {
        "statusCode": 200,
        "body": json.dumps({
            "email": body["email"]
        }, default=str)
    }



def validate_email(email: str) -> bool:
    """Validate the email address format."""
    if not email or "@" not in email or "." not in email:
        return False
    return True