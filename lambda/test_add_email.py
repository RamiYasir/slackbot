import json
from handler import handler


def test_returns_email() -> None:
    event_mock: dict = {
        "headers": None,
        "body": json.dumps({
                "email": "alice@example.com"
            }),
        "isBase64Encoded": False
    }

    response = handler(event_mock, None)
    body = json.loads(response["body"])

    assert response["statusCode"] == 200
    assert body["email"] == "alice@example.com"