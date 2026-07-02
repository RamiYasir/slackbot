module "api" {
  source = "./modules/api_gateway"

  emails_lambda_invoke_arn = module.lambda.emails_lambda_invoke_arn
}

module "lambda" {
  source = "./modules/lambda"

  emails_table_ddb_arn = module.dynamodb.emails_table_arn
}

module "dynamodb" {
  source = "./modules/dynamoDB"
}