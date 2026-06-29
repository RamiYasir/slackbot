module "api" {
  source = "./modules/api_gateway"
}

module "lambda" {
  source = "./modules/lambda"

  emails_table_ddb_arn = module.dynamodb.emails_table_arn
}

module "dynamodb" {
  source = "./modules/dynamoDB"
}