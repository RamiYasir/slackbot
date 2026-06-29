# We create an iam role, policies to allow it to write to dynamoDB and cloudwatch,
# and give that role to the lambda.  

resource "aws_iam_role" "lambda_role" {
  name = "email_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "lambda.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "write_to_dynamodb_policy" {
  name = "write_to_emails_table_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
        ]
        Resource = aws_dynamodb_table.emails.arn
      }
    ]
  })
}

# resource "aws_iam_role_policy" "write_to_cloudwatch_policy" {
#   name = "email_lambda_cloudwatch_policy"

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#         ]
#         Resource = "*"
#       }
#     ]
#   })
# }

resource "aws_iam_role_policy_attachment" "write_to_dynamodb_attach" {
    role = aws_iam_role.lambda_role.name
    policy_arn = aws_iam_policy.write_to_dynamodb_policy.arn
}