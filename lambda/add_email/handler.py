import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)


def handler(event, context) -> dict:
    body = json.loads(event["body"])
    logger.info(f"Parsed body: {body}")

    # Validate the input
    email = body.get("email")

    if not validate_email(email):
        logger.error(f"Invalid email address: {email}")
        return {
            "statusCode": 422,  # Unprocessable Entity
            "body": json.dumps({
                "error": "Invalid email address"
            }, default=str)
        }

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