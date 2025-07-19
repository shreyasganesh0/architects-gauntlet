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

resource "aws_cognito_user_pool_client" "client" {

  name = "creator-platform-client"

  user_pool_id = aws_cognito_user_pool.creator_user_pool.id
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
}

