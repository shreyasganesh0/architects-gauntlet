# main.tf

provider "aws" {

	region = "us-east-1"

}

resource "random_string" "bucket_suffix" {

	length = 8
	special = false
	upper = false
}

resource "aws_s3_bucket" "uploads" {

	bucket = "architects-gauntlet-uploads-${random_string.bucket_suffix.result}"
	force_destroy = true 
	# would be false with proper lifecycle management
	# set as true for dev startup purposes
}

resource "aws_iam_role" "url_generator_role" {

	name = "url-generator-lambda-role"
	assume_role_policy = jsonencode({
		Version = "2012-10-17",
		Statement = [
			{
				Effect = "Allow",
				Action = "sts:AssumeRole",
				Principal = { 
					Service = "lambda.amazonaws.com"
        }
			}
		]
	})
}


resource "aws_iam_policy" "url_generator_policy" {

	name = "s3-upload-permissions-policy"
	policy = jsonencode({
		Version = "2012-10-17",
		Statement = [
			{
				Effect = "Allow",
				Action = "s3:PutObject",
				Resource = "${aws_s3_bucket.uploads.arn}/*"
			}
		]
	})
}


resource "aws_iam_role_policy_attachment" "connect_policy_to_role" {
	
	role = aws_iam_role.url_generator_role.name
	policy_arn = aws_iam_policy.url_generator_policy.arn
}

resource "aws_cognito_user_pool" "creator_user_pool" {

  name = "creator-platform-user-pool"
}

resource "aws_cognito_user_pool_client" "creator_client" {

  name                   = "creator-platform-client"
  user_pool_id           = aws_cognito_user_pool.creator_user_pool.id
  access_token_validity  = 5
  id_token_validity      = 5
  refresh_token_validity = 10
}

# zip the lambda code
data "archive_file" "url_generator" {

  type = "zip"
  source_file = "${path.module}/bootstrap"
  output_path = "${path.module}/aws/lambda/function.zip"
}

resource "aws_lambda_function" "url_generator" {
  filename         = data.archive_file.url_generator.output_path
  function_name    = "url_generator_function"
  role             = aws_iam_role.url_generator_role.arn
  handler          = data.archive_file.url_generator.source_file
  runtime          = "provided.al2"
  source_code_hash = data.archive_file.url_generator.output_base64sha256

  environment {
    variables = {
      "UPLOAD_BUCKET" = aws_s3_bucket.uploads.bucket 
    }
  }
}


resource "aws_iam_role_policy_attachment" "connect_lambda_cloudwatch_policy_to_role" {
	
	role       = aws_iam_role.url_generator_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_apigatewayv2_api" "upload_lambda_gw" {

  name          = "creator_platform_gw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "upload_url_lambda" {
  
  api_id           = aws_apigatewayv2_api.upload_lambda_gw.id
  integration_type = "AWS_PROXY"

  integration_uri  = aws_lambda_function.url_generator.invoke_arn
}

resource "aws_lambda_permission" "upload_url_invoke" {

  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.url_generator.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.upload_lambda_gw.execution_arn}/*/*"
}

resource "aws_apigatewayv2_route" "get_uploads_urls" {

  api_id = aws_apigatewayv2_api.upload_lambda_gw.id
  route_key = "GET /get-upload-url"

  target = "integrations/${aws_apigatewayv2_integration.upload_url_lambda.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.upload_url.id
}

resource "aws_apigatewayv2_stage" "upload_url" {

  name = "$default"
  api_id = aws_apigatewayv2_api.upload_lambda_gw.id
  auto_deploy = true
}

output "upload_url_api_endpoint" {

  description = "URL of upload gateway endpoint"
  value       = aws_apigatewayv2_api.upload_lambda_gw.api_endpoint

}

resource "aws_apigatewayv2_authorizer" "upload_url" {

  name             = "upload_url_authorizer"
  api_id           = aws_apigatewayv2_api.upload_lambda_gw.id
  authorizer_type  = "JWT"
  authorizer_uri   = aws_lambda_function.url_generator.invoke_arn
  identity_sources = ["$request.header.Authorization"]

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.creator_client.id] 
    issuer = "https://${aws_cognito_user_pool.creator_user_pool.endpoint}"
  }
}

output "cognito_user_pool_id" {
  description = "Id of the cognito authorizer pool"
  value       = aws_cognito_user_pool.creator_user_pool.id
}

output "cognito_user_pool_client_id" {
  description = "Id of the cognito authorizer pool client"
  value       = aws_cognito_user_pool_client.creator_client.id
}
