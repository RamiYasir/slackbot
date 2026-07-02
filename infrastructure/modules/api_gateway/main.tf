resource "aws_api_gateway_rest_api" "api" {
    name = "reminder-api"
    description = "API for managing timesheet reminders"
}

resource "aws_api_gateway_resource" "root" {
    rest_api_id = aws_api_gateway_rest_api.api.id
    parent_id   = aws_api_gateway_rest_api.api.root_resource_id
    path_part   = "reminders"
}

resource "aws_api_gateway_resource" "add_email" {
    rest_api_id = aws_api_gateway_rest_api.api.id
    parent_id   = aws_api_gateway_resource.root.id
    path_part   = "add-email"
}

resource "aws_api_gateway_model" "email_model" {
    rest_api_id = aws_api_gateway_rest_api.api.id
    name        = "EmailModel"
    content_type = "application/json"
    schema = jsonencode({
        type = "object"
        properties = {
            email = {
                type = "string"
            }
        }
        required = ["email"]
    })

}


# POST method
resource "aws_api_gateway_request_validator" "request_validator" {
    rest_api_id = aws_api_gateway_rest_api.api.id
    name        = "validator"
    validate_request_body = true
    validate_request_parameters = false
}

resource "aws_api_gateway_method" "add_email" {
    rest_api_id   = aws_api_gateway_rest_api.api.id
    resource_id   = aws_api_gateway_resource.add_email.id
    http_method   = "POST"
    authorization = "NONE"

    request_validator_id = aws_api_gateway_request_validator.request_validator.id
    request_models = {
        "application/json" = aws_api_gateway_model.email_model.name
    }
}

# Defines what is sent to the lambda
resource "aws_api_gateway_integration" "lambda_integration" {
    rest_api_id = aws_api_gateway_rest_api.api.id
    resource_id = aws_api_gateway_resource.add_email.id
    http_method = aws_api_gateway_method.add_email.http_method
    
    integration_http_method = "POST"
    type = "AWS_PROXY"

    uri = var.emails_lambda_invoke_arn
}


# OPTIONS method
resource "aws_api_gateway_method" "add_email_options" {
    rest_api_id   = aws_api_gateway_rest_api.api.id
    resource_id   = aws_api_gateway_resource.add_email.id
    http_method   = "OPTIONS"
    authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integration" {
    rest_api_id = aws_api_gateway_rest_api.api.id
    resource_id = aws_api_gateway_resource.add_email.id
    http_method = aws_api_gateway_method.add_email_options.http_method
    
    integration_http_method = "OPTIONS"
    type = "MOCK"
}

resource "aws_api_gateway_method_response" "add_email_options_response" {
    rest_api_id = aws_api_gateway_rest_api.api.id
    resource_id = aws_api_gateway_resource.add_email.id
    http_method = aws_api_gateway_method.add_email_options.http_method
    status_code = "200"

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = true,
        "method.response.header.Access-Control-Allow-Methods" = true,
        "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_response" {
    rest_api_id = aws_api_gateway_rest_api.api.id
    resource_id = aws_api_gateway_resource.add_email.id
    http_method = aws_api_gateway_method.add_email_options.http_method
    status_code = aws_api_gateway_method_response.add_email_options_response.status_code

    response_parameters = {
        "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
        "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
        "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

    depends_on = [
                  aws_api_gateway_method.add_email_options,
                  aws_api_gateway_integration.options_integration
                ]
}


# Deployment and stage
resource "aws_api_gateway_deployment" "deployment" {
    depends_on = [
        aws_api_gateway_method.add_email,
        aws_api_gateway_integration.lambda_integration,
        aws_api_gateway_method.add_email_options,
        aws_api_gateway_method_response.add_email_options_response,
        aws_api_gateway_integration_response.options_integration_response,
        aws_api_gateway_integration.options_integration,
    ]

    # ensures a new deployment is created before destroying the old one
    lifecycle {
        create_before_destroy = true
    }

    # forces a new deployment whenever the API configuration changes
    triggers = {
        redeploy = timestamp()
    }

    rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_stage" "stage" {
    rest_api_id   = aws_api_gateway_rest_api.api.id
    deployment_id = aws_api_gateway_deployment.deployment.id
    stage_name    = "dev"
}