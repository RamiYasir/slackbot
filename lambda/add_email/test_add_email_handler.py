import json
import os
import pytest
import boto3
from moto import mock_aws

from handler import handler


os.environ.pop("DYNAMO_DB_ENDPOINT", None)  # Ensure the env var is not set for testing


@pytest.fixture(autouse=True)
def setup_function():
    with mock_aws():
        ddb_mock = boto3.resource("dynamodb", region_name="us-east-1")
        ddb_mock.create_table(
            TableName="emails",
            BillingMode="PAY_PER_REQUEST",
            KeySchema=[
                {
                    "AttributeName": "email",
                    "KeyType": "HASH"
                }
            ],
            AttributeDefinitions=[
                {
                    "AttributeName": "email",
                    "AttributeType": "S"
                }
            ]
        )
        yield ddb_mock


@pytest.mark.parametrize(
    "email",
    [
        ("notarealemail"),
        (""),
        ("missing-at-sign.com"),
        ("user@"),
    ],
)
def test_input_validated(email: str, setup_function) -> None:
    event_mock = {
        "headers": None,
        "body": json.dumps({
                "slackId": "U12345678",
                "email": email
            }),
        "isBase64Encoded": False
    }

    response = handler(event_mock, None)
    body = json.loads(response["body"])

    assert response["statusCode"] == 422 # Unprocessable Entity
    assert body["error"] == "Invalid email address"


def test_successful_PUT_to_dynamodb(setup_function) -> None:
    event_mock = {
        "headers": None,
        "body": json.dumps({
                "slackId": "U12345678",
                "email": "alice@example.com"
            }),
        "isBase64Encoded": False
    }

    response = handler(event_mock, None)
    emails_table = setup_function.Table("emails")

    items = emails_table.scan().get("Items")
    
    assert len(items) > 0
    assert response["statusCode"] == 200