output "emails_lambda_invoke_arn" {
  value = aws_lambda_function.add_email.invoke_arn
}