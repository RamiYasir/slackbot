import json

def handler(event, context) -> dict:
    body = json.loads(event["body"])
    return {"statusCode": 200, "body": json.dumps({"email": body["email"]})}