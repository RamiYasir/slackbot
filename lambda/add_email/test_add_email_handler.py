import json
import pytest

from handler import handler


def test_returns_email() -> None:
    event_mock = {
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


@pytest.mark.parametrize(
    "email",
    [
        ("notarealemail"),
        (""),
        ("missing-at-sign.com"),
        ("user@"),
    ],
)
def test_input_validated(email: str) -> None:
    event_mock = {
        "headers": None,
        "body": json.dumps({
                "email": email
            }),
        "isBase64Encoded": False
    }

    print(email)
    response = handler(event_mock, None)
    body = json.loads(response["body"])
    assert response["statusCode"] == 422 # Unprocessable Entity
    assert body["error"] == "Invalid email address"