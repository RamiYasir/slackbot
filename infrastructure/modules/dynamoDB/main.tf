resource "aws_dynamodb_table" "emails" {
    name         = "emails"
    billing_mode = "PAY_PER_REQUEST"

    hash_key = "slackId"

    attribute {
        name = "slackId"
        type = "S"
    }
}